require 'spec_helper'
require 'capybara/driver/webkit/connection'

describe Capybara::Driver::Webkit::Connection do
  it "boots a server to talk to" do
    url = @rack_server.url("/")
    connection.puts "Visit"
    connection.puts 1
    connection.puts url.to_s.bytesize
    connection.print url
    connection.gets.should == "ok\n"
    connection.gets.should == "0\n"
    connection.puts "Body"
    connection.puts 0
    connection.gets.should == "ok\n"
    response_length = connection.gets.to_i
    response = connection.read(response_length)
    response.should include("Hey there")
  end

  it 'forwards stdout to the given IO object' do
    io = StringIO.new
    redirected_connection = Capybara::Driver::Webkit::Connection.new(:stdout => io)
    script = 'console.log("hello world")'
    redirected_connection.puts "Execute"
    redirected_connection.puts 1
    redirected_connection.puts script.to_s.bytesize
    redirected_connection.print script
    sleep(0.5)
    io.string.should include "hello world\n"
  end

  it "returns the server port" do
    connection.port.should be_between 0x400, 0xffff
  end

  it "chooses a new port number for a new connection" do
    new_connection = Capybara::Driver::Webkit::Connection.new
    new_connection.port.should_not == connection.port
  end

  let(:connection) { Capybara::Driver::Webkit::Connection.new }

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
