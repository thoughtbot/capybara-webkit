require 'spec_helper'
require 'self_signed_ssl_cert'
require 'stringio'
require 'capybara/driver/webkit/browser'
require 'capybara/driver/webkit/socket_debugger'
require 'socket'
require 'base64'

describe Capybara::Driver::Webkit::Browser do

  let(:blacklist_file) { File.join(File.dirname(__FILE__), 'support/test_blacklist.txt') }
  let(:browser) { Capybara::Driver::Webkit::Browser.new }
  let(:browser_with_blacklist) { Capybara::Driver::Webkit::Browser.new(blacklist_file: blacklist_file)}
  let(:browser_ignore_ssl_err) {
    Capybara::Driver::Webkit::Browser.new(:ignore_ssl_errors => true)
  }
  let(:browser_skip_images) {
    Capybara::Driver::Webkit::Browser.new(:skip_image_loading => true)
  }

  describe '#server_port' do
    subject { browser.server_port }
    it 'returns a valid port number' do
      should be_a(Integer)
    end

    it 'returns a port in the allowed range' do
      should be_between 0x400, 0xffff
    end
  end

  context 'random port' do
    it 'chooses a new port number for a new browser instance' do
      new_browser = Capybara::Driver::Webkit::Browser.new
      new_browser.server_port.should_not == browser.server_port
    end
  end

  it 'forwards stdout to the given IO object' do
    io = StringIO.new
    new_browser = Capybara::Driver::Webkit::Browser.new(:stdout => io)
    new_browser.execute_script('console.log("hello world")')
    sleep(0.5)
    io.string.should include "hello world\n"
  end

  context 'handling of SSL validation errors' do
    before do
      # set up minimal HTTPS server
      @host = "127.0.0.1"
      @server = TCPServer.new(@host, 0)
      @port = @server.addr[1]

      # set up SSL layer
      ssl_serv = OpenSSL::SSL::SSLServer.new(@server, $openssl_self_signed_ctx)

      @server_thread = Thread.new(ssl_serv) do |serv|
        while conn = serv.accept do
          # read request
          request = []
          until (line = conn.readline.strip).empty?
            request << line
          end

          # write response
          html = "<html><body>D'oh!</body></html>"
          conn.write "HTTP/1.1 200 OK\r\n"
          conn.write "Content-Type:text/html\r\n"
          conn.write "Content-Length: %i\r\n" % html.size
          conn.write "\r\n"
          conn.write html
          conn.close
        end
      end
    end

    after do
      @server_thread.kill
      @server.close
    end

    it "doesn't accept a self-signed certificate by default" do
      lambda { browser.visit "https://#{@host}:#{@port}/" }.should raise_error
    end

    it 'accepts a self-signed certificate if configured to do so' do
      browser_ignore_ssl_err.visit "https://#{@host}:#{@port}/"
    end
  end

  context "skip image loading" do
    before(:each) do
      # set up minimal HTTPS server
      @host = "127.0.0.1"
      @server = TCPServer.new(@host, 0)
      @port = @server.addr[1]
      @received_requests = []

      # set up SSL layer

      @server_thread = Thread.new(@server) do |serv|
        while conn = serv.accept do
          # read request
          request = []
          until (line = conn.readline.strip).empty?
            request << line
          end

          @received_requests << request.join("\n")

          # write response          
          html = <<-HTML
            <html>
              <head>
                <style> 
                  body {
                    background-image: url(/path/to/bgimage);
                  }
                </style>
              </head>
              <body>
                <img src="/path/to/image"/>
              </body>
            </html>
        HTML
          conn.write "HTTP/1.1 200 OK\r\n"
          conn.write "Content-Type:text/html\r\n"
          conn.write "Content-Length: %i\r\n" % html.size
          conn.write "\r\n"
          conn.write html
          conn.write("\r\n\r\n")
          conn.close
        end
      end
    end

    after(:each) do
      @server_thread.kill
      @server.close
    end

    it "should load images in image tags by default" do
      browser.visit("http://#{@host}:#{@port}/")
      @received_requests.find {|r| r =~ %r{/path/to/image}   }.should_not be_nil
    end

    it "should load images in css by default" do
      browser.visit("http://#{@host}:#{@port}/")
      @received_requests.find {|r| r =~ %r{/path/to/image}   }.should_not be_nil
    end

    it "should not load images in image tags when skip_image_loading is true" do
      browser_skip_images.visit("http://#{@host}:#{@port}/")
      @received_requests.find {|r| r =~ %r{/path/to/image} }.should be_nil
    end

    it "should not load images in css when skip_image_loading is true" do
      browser_skip_images.visit("http://#{@host}:#{@port}/")
      @received_requests.find {|r| r =~ %r{/path/to/bgimage} }.should be_nil
    end
  end

  context "uses the url blacklist" do
    before(:each) do
      # set up minimal HTTP server
      @host = "127.0.0.1"
      @server = TCPServer.new(@host, 0)
      @port = @server.addr[1]

      @server_thread = Thread.new(@server) do |serv|
        while conn = serv.accept do
          # read request
          request = []
          until (line = conn.readline.strip).empty?
            request << line
          end

          request = request.join("\n")
          content = if request =~ %r{GET /frame}
            "<p>Inner</p>"
          else
            <<-HTML
              <iframe src="http://example.com/path" id="frame1"></iframe>
              <iframe src="http://example.org/path/to/file" id="frame2"></iframe>
              <iframe src="/frame" id="frame3"></iframe>
            HTML
          end

          html = <<-HTML
            <html>
              <head>
              </head>
              <body>
                #{content}
              </body>
            </html>
          HTML
          conn.write "HTTP/1.1 200 OK\r\n"
          conn.write "Content-Type: text/html\r\n"
          conn.write "Content-Length: %i\r\n" % html.size
          conn.write "\r\n"
          conn.write html
          conn.write("\r\n\r\n")
          conn.close
        end
      end
    end

    after(:each) do
      @server_thread.kill
      @server.close
    end

    it "should not fetch urls blocked by host" do
      browser_with_blacklist.visit("http://#{@host}:#{@port}")
      browser_with_blacklist.frame_focus('frame1')
      browser_with_blacklist.find('//body').should be_empty
    end

    it "should not fetch urls blocked by full paths" do
      browser_with_blacklist.visit("http://#{@host}:#{@port}")
      browser_with_blacklist.frame_focus('frame2')
      browser_with_blacklist.find('//body').should be_empty
    end

    it "should not block non-blacklisted urls" do
      browser_with_blacklist.visit("http://#{@host}:#{@port}")
      browser_with_blacklist.frame_focus('frame3')
      browser_with_blacklist.find('//p').should_not be_empty
    end
  end

  context "timeout on long requests" do
    before(:each) do
      # set up minimal HTTPS server
      @host = "127.0.0.1"
      @server = TCPServer.new(@host, 0)
      @port = @server.addr[1]

      # set up SSL layer

      @server_thread = Thread.new(@server) do |serv|
        while conn = serv.accept do
          begin
            # read request
            request = []
            until (line = conn.readline.strip).empty?
              request << line
            end

            request = request.join("\n")

            if request =~ %r{POST /form}
              sleep(4)
            else
              sleep(2)
            end

            # write response
            html = <<-HTML
            <html>
              <body>
                <form action="/form" method="post">
                  <input type="submit" value="Submit"/>
                </form>
              </body>
            </html>
            HTML
            conn.write "HTTP/1.1 200 OK\r\n"
            conn.write "Content-Type:text/html\r\n"
            conn.write "Content-Length: %i\r\n" % html.size
            conn.write "\r\n"
            conn.write html
            conn.write("\r\n\r\n")
            conn.close
          rescue 
            conn.close
          end
        end
      end
    end

    after(:each) do
      @server_thread.kill
      @server.close
    end

    it "should not raise a timeout error when zero" do
      browser.set_timeout(0)
      lambda { browser.visit("http://#{@host}:#{@port}/") }.should_not raise_error(Capybara::TimeoutError)
    end

    it "should raise a timeout error" do
      browser.set_timeout(1)
      lambda { browser.visit("http://#{@host}:#{@port}/") }.should raise_error(Capybara::TimeoutError)
    end

    it "should not raise an error when the timeout is high enough" do
      browser.set_timeout(10)
      lambda { browser.visit("http://#{@host}:#{@port}/") }.should_not raise_error(Capybara::TimeoutError)
    end

    it "should set the timeout for each request" do
      browser.set_timeout(10)
      lambda { browser.visit("http://#{@host}:#{@port}/") }.should_not raise_error(Capybara::TimeoutError)
      browser.set_timeout(1)
      lambda { browser.visit("http://#{@host}:#{@port}/") }.should raise_error(Capybara::TimeoutError) 
    end

    it "should set the timeout for each request" do
      browser.set_timeout(1)
      lambda { browser.visit("http://#{@host}:#{@port}/") }.should raise_error(Capybara::TimeoutError)
      browser.reset!
      browser.set_timeout(10)
      lambda { browser.visit("http://#{@host}:#{@port}/") }.should_not raise_error(Capybara::TimeoutError)
    end

    it "should raise a timeout on a slow form" do
      browser.set_timeout(3)
      browser.visit("http://#{@host}:#{@port}/")
      browser.status_code.should == 200
      browser.set_timeout(1)
      browser.command("Node", "click", browser.find("//input").first)
      lambda { browser.status_code }.should raise_error(Capybara::TimeoutError)
    end

    it "get timeout" do
      browser.set_timeout(10)
      browser.get_timeout.should == 10
      browser.set_timeout(3)
      browser.get_timeout.should == 3
    end
  end

  describe "forking", :skip_on_windows => true do
    it "only shuts down the server from the main process" do
      browser.reset!
      pid = fork {}
      Process.wait(pid)
      expect { browser.reset! }.not_to raise_error
    end
  end

  describe '#set_proxy' do
    before do
      @host = '127.0.0.1'
      @user = 'user'
      @pass = 'secret'
      @url  = "http://example.org/"

      @server = TCPServer.new(@host, 0)
      @port = @server.addr[1]

      @proxy_requests = []
      @proxy = Thread.new(@server, @proxy_requests) do |serv, proxy_requests|
        while conn = serv.accept do
          # read request
          request = []
          until (line = conn.readline.strip).empty?
            request << line
          end

          # send response
          auth_header = request.find { |h| h =~ /Authorization:/i }
          if auth_header || request[0].split(/\s+/)[1] =~ /^\//
            html = "<html><body>D'oh!</body></html>"
            conn.write "HTTP/1.1 200 OK\r\n"
            conn.write "Content-Type:text/html\r\n"
            conn.write "Content-Length: %i\r\n" % html.size
            conn.write "\r\n"
            conn.write html
            conn.close
            proxy_requests << request if auth_header
          else
            conn.write "HTTP/1.1 407 Proxy Auth Required\r\n"
            conn.write "Proxy-Authenticate: Basic realm=\"Proxy\"\r\n"
            conn.write "\r\n"
            conn.close
            proxy_requests << request
          end
        end
      end

      browser.set_proxy(:host => @host,
                        :port => @port,
                        :user => @user,
                        :pass => @pass)
      browser.visit @url
      @proxy_requests.size.should == 2
      @request = @proxy_requests[-1]
    end

    after do
      @proxy.kill
      @server.close
    end

    it 'uses the HTTP proxy correctly' do
      @request[0].should match /^GET\s+http:\/\/example.org\/\s+HTTP/i
      @request.find { |header|
        header =~ /^Host:\s+example.org$/i }.should_not be nil
    end

    it 'sends correct proxy authentication' do
      auth_header = @request.find { |header|
        header =~ /^Proxy-Authorization:\s+/i }
      auth_header.should_not be nil

      user, pass = Base64.decode64(auth_header.split(/\s+/)[-1]).split(":")
      user.should == @user
      pass.should == @pass
    end

    it "uses the proxies' response" do
      browser.body.should include "D'oh!"
    end

    it 'uses original URL' do
      browser.url.should == @url
    end

    it 'uses URLs changed by javascript' do
      browser.execute_script "window.history.pushState('', '', '/blah')"
      browser.requested_url.should == 'http://example.org/blah'
    end

    it 'is possible to disable proxy again' do
      @proxy_requests.clear
      browser.clear_proxy
      browser.visit "http://#{@host}:#{@port}/"
      @proxy_requests.size.should == 0
    end
  end
end
