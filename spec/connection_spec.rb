require 'spec_helper'
require 'capybara/webkit/connection'

describe Capybara::Webkit::Connection do
  it "boots a server to talk to" do
    url = "http://#{@rack_server.host}:#{@rack_server.port}/"
    connection.puts "Visit"
    connection.puts 1
    connection.puts url.to_s.bytesize
    connection.print url
    expect(connection.gets).to eq "ok\n"
    expect(connection.gets).to eq "0\n"
    connection.puts "Body"
    connection.puts 0
    expect(connection.gets).to eq "ok\n"
    response_length = connection.gets.to_i
    response = connection.read(response_length)
    expect(response).to include("Hey there")
  end

  it 'forwards stderr to the given IO object' do
    read_io, write_io = IO.pipe
    redirected_connection = Capybara::Webkit::Connection.new(:stderr => write_io)
    redirected_connection.puts "EnableLogging"
    redirected_connection.puts 0

    script = 'console.log("hello world")'
    redirected_connection.puts "Execute"
    redirected_connection.puts 1
    redirected_connection.puts script.to_s.bytesize
    redirected_connection.print script

    expect(read_io).to include_response "\nhello world"
  end

  it 'does not forward stderr to nil' do
    expect(IO).not_to receive(:copy_stream)
    Capybara::Webkit::Connection.new(:stderr => nil)
  end

  it 'prints a deprecation warning if the stdout option is used' do
    expect_any_instance_of(Capybara::Webkit::Connection).to receive(:warn)
    Capybara::Webkit::Connection.new(:stdout => nil)
  end

  it 'does not forward stdout to nil if the stdout option is used' do
    allow_any_instance_of(Capybara::Webkit::Connection).to receive(:warn)
    expect(IO).not_to receive(:copy_stream)
    Capybara::Webkit::Connection.new(:stdout => nil)
  end

  it "returns the server port" do
    expect(connection.port).to be_between 0x400, 0xffff
  end

  it 'sets appropriate options on its socket' do
    socket = double('socket')
    allow(TCPSocket).to receive(:open).and_return(socket)
    if defined?(Socket::TCP_NODELAY)
      expect(socket).to receive(:setsockopt).with(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, true)
    else
      expect(socket).not_to receive(:setsockopt)
    end
    Capybara::Webkit::Connection.new
  end

  it "chooses a new port number for a new connection" do
    new_connection = Capybara::Webkit::Connection.new
    expect(new_connection.port).not_to eq(connection.port)
  end

  let(:connection) { Capybara::Webkit::Connection.new }

  before(:all) do
    @app = lambda do |env|
      body = "<html><body>Hey there</body></html>"
      [200,
        { 'Content-Type' => 'text/html', 'Content-Length' => body.size.to_s },
        [body]]
    end
    @rack_server = Capybara::Server.new(@app)
    @rack_server.boot
  end
end
