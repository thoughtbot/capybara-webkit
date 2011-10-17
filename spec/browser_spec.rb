require 'spec_helper'
require 'self_signed_ssl_cert'
require 'stringio'
require 'capybara/driver/webkit/browser'
require 'socket'
require 'base64'

describe Capybara::Driver::Webkit::Browser do

  let(:browser) { Capybara::Driver::Webkit::Browser.new }
  let(:browser_ignore_ssl_err) {
    Capybara::Driver::Webkit::Browser.new(:ignore_ssl_errors => true)
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
    io.string.should == "hello world\n"
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
  describe "forking" do
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

    it 'is possible to disable proxy again' do
      @proxy_requests.clear
      browser.clear_proxy
      browser.visit "http://#{@host}:#{@port}/"
      @proxy_requests.size.should == 0
    end
  end
end
