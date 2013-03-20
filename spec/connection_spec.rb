require 'spec_helper'
require 'capybara/webkit/connection'

describe Capybara::Webkit::Connection do
  it "starts a Webkit session" do
    url = "http://#{@rack_server.host}:#{@rack_server.port}/"
    connection.puts "Visit"
    connection.puts 1
    connection.puts url.to_s.bytesize
    connection.print url
    puts 'about to gets'
    connection.gets.should == "ok\n"
    puts 'first gets is a go'
    connection.gets.should == "0\n"
    connection.puts "Body"
    connection.puts 0
    connection.gets.should == "ok\n"
    response_length = connection.gets.to_i
    response = connection.read(response_length)
    response.should include("Hey there")
  end

  it 'forwards stderr to the given IO object' do
    io = StringIO.new
    redirected_connection = Capybara::Webkit::Connection.new(:stderr => io)
    script = 'console.log("hello world")'
    redirected_connection.puts "EnableLogging"
    redirected_connection.puts 0
    redirected_connection.puts "Execute"
    redirected_connection.puts 1
    redirected_connection.puts script.to_s.bytesize
    redirected_connection.print script
    sleep(0.5)
    io.string.should =~ /hello world $/
  end

  it 'does not forward stderr to nil' do
    IO.should_not_receive(:copy_stream)
    Capybara::Webkit::Connection.new(:stderr => nil)
  end

  it 'prints a deprecation warning if the stdout option is used' do
    Capybara::Webkit::Connection.any_instance.should_receive(:warn)
    Capybara::Webkit::Connection.new(:stdout => nil)
  end

  it 'does not forward stdout to nil if the stdout option is used' do
    Capybara::Webkit::Connection.any_instance.stub(:warn)
    IO.should_not_receive(:copy_stream)
    Capybara::Webkit::Connection.new(:stdout => nil)
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
