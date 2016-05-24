require 'spec_helper'
require 'self_signed_ssl_cert'
require 'stringio'
require 'capybara/webkit/driver'
require 'socket'
require 'base64'

describe Capybara::Webkit::Browser do

  let(:server) { Capybara::Webkit::Server.new }
  let(:connection) { Capybara::Webkit::Connection.new(server: server) }
  let(:browser) { Capybara::Webkit::Browser.new(connection) }

  describe "forking", skip_on_windows: true, skip_on_jruby: true do
    it "only shuts down the server from the main process" do
      browser.reset!
      pid = fork {}
      Process.wait(pid)
      expect { browser.reset! }.not_to raise_error
    end
  end
<<<<<<< HEAD
  it 'test' do
    require 'socket'
    include Socket::Constants
    socket = Socket.new( AF_INET, SOCK_STREAM, 0 )
    socket.listen( 1 )
  end
  describe '#set_proxy' do
    context 'type: http' do
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
        @proxy_requests.size.should eq 2
        @request = @proxy_requests[-1]
      end

      after do
        @proxy.kill
        @server.close
      end

      it 'uses the HTTP proxy correctly' do
        @request[0].should match(/^GET\s+http:\/\/example.org\/\s+HTTP/i)
        @request.find { |header|
          header =~ /^Host:\s+example.org$/i }.should_not be nil
      end

      it 'sends correct proxy authentication' do
        auth_header = @request.find { |header|
          header =~ /^Proxy-Authorization:\s+/i }
        auth_header.should_not be nil

        user, pass = Base64.decode64(auth_header.split(/\s+/)[-1]).split(":")
        user.should eq @user
        pass.should eq @pass
      end

      it "uses the proxies' response" do
        browser.body.should include "D'oh!"
      end

      it 'uses original URL' do
        browser.current_url.should eq @url
      end

      it 'uses URLs changed by javascript' do
        browser.execute_script "window.history.pushState('', '', '/blah')"
        browser.current_url.should eq 'http://example.org/blah'
      end

      it 'is possible to disable proxy again' do
        @proxy_requests.clear
        browser.clear_proxy
        browser.visit "http://#{@host}:#{@port}/"
        @proxy_requests.size.should eq 0
      end
    end
    context 'type: :sock5' do
      before do
        @host = '127.0.0.1'
        @user = 'user'
        @pass = 'secret'
        @url  = "http://example.org/"

        @server = TCPServer.new(@host, 2000)
        @port = @server.addr[1]
        @proxy_requests = []
        @proxy = Thread.new(@server, @proxy_requests) do |serv, proxy_requests|
          while conn = serv.accept do
              html = "<html><body>D'oh!</body></html>"
              conn.write "HTTP/1.1 200 OK\r\n"
              conn.write "Content-Type:text/html\r\n"
              conn.write "Content-Length: %i\r\n" % html.size
              conn.write "\r\n"
              conn.write html
            conn.close
            # # read request
            # request = []
            # until (line = conn.readline.strip).empty?
            #   request << line
            # end
            # p request
            # # send response
            # auth_header = request.find { |h| h =~ /Authorization:/i }
            # if auth_header || request[0].split(/\s+/)[1] =~ /^\//
            #   html = "<html><body>D'oh!</body></html>"
            #   conn.write "HTTP/1.1 200 OK\r\n"
            #   conn.write "Content-Type:text/html\r\n"
            #   conn.write "Content-Length: %i\r\n" % html.size
            #   conn.write "\r\n"
            #   conn.write html
            #   conn.close
            #   proxy_requests << request if auth_header
            # else
            #   conn.write "HTTP/1.1 407 Proxy Auth Required\r\n"
            #   conn.write "Proxy-Authenticate: Basic realm=\"Proxy\"\r\n"
            #   conn.write "\r\n"
            #   conn.close
            #   proxy_requests << request
            # end
          end
        end

        browser.set_proxy(:host => @host,
                          :port => @port,
                          :user => @user,
                          :pass => @pass,
                          :type => :socks5
        )
        browser.allow_url @url
        browser.visit @url
        @proxy_requests.size.should eq 2
        @request = @proxy_requests[-1]
      end

      after do
        @proxy.kill
        @server.close
      end

      it 'uses the Socks proxy correctly' do
        @request[0].should match(/^GET\s+http:\/\/example.org\/\s+HTTP/i)
        @request.find { |header|
          header =~ /^Host:\s+example.org$/i }.should_not be nil
      end

      it 'sends correct proxy authentication' do
        p @request
        auth_header = @request.find { |header|
          header =~ /^Proxy-Authorization:\s+/i }
        auth_header.should_not be nil

        user, pass = Base64.decode64(auth_header.split(/\s+/)[-1]).split(":")
        user.should eq @user
        pass.should eq @pass
      end

      it "uses the proxies' response" do
        browser.body.should include "D'oh!"
      end

      it 'uses original URL' do
        browser.current_url.should eq @url
      end

      it 'uses URLs changed by javascript' do
        browser.execute_script "window.history.pushState('', '', '/blah')"
        browser.current_url.should eq 'http://example.org/blah'
      end

      it 'is possible to disable proxy again' do
        @proxy_requests.clear
        browser.clear_proxy
        browser.visit "http://#{@host}:#{@port}/"
        @proxy_requests.size.should eq 0
      end
    end
  end
=======
>>>>>>> 3ef6732baa2a3ed7a1b7ba5d6a464485779cebd4

  it "doesn't try to read an empty response" do
    connection = double("connection")
    connection.stub(:puts)
    connection.stub(:print)
    connection.stub(:gets).and_return("ok\n", "0\n")
    connection.stub(:read).and_raise(StandardError.new("tried to read empty response"))

    browser = Capybara::Webkit::Browser.new(connection)

    expect { browser.visit("/") }.not_to raise_error
  end

  describe '#command' do
    context 'non-ok response' do
      it 'raises an error of given class' do
        error_json = '{"class": "ClickFailed"}'

        connection.should_receive(:gets).ordered.and_return 'error'
        connection.should_receive(:gets).ordered.and_return error_json.bytesize
        connection.stub read: error_json

        expect { browser.command 'blah', 'meh' }.to raise_error(Capybara::Webkit::ClickFailed)
      end
    end
  end
end
