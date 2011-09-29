require 'spec_helper'
require 'self_signed_ssl_cert'
require 'stringio'
require 'capybara/driver/webkit/browser'

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
      serv = TCPServer.new(@host, 0)
      @port = serv.addr[1]

      # set up SSL layer
      serv = OpenSSL::SSL::SSLServer.new(serv, $openssl_self_signed_ctx)

      @server_thread = Thread.new(serv) do |serv|
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

end
