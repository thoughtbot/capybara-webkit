require "spec_helper"
require "capybara/webkit/server"

describe Capybara::Webkit::Connection do
  it "ensures the process ends", skip_on_windows: true, skip_on_jruby: true do
    read_io, write_io = IO.pipe

    fork_pid = fork do
      read_io.close
      server = start_server
      write_io.write(server.pid)
      write_io.close
      Process.wait(server.pid)
    end

    write_io.close

    webkit_pid = read_io.read.to_i
    webkit_pid.should be > 1
    read_io.close
    Process.kill(9, fork_pid)

    eventually do
      expect { Process.getpgid(webkit_pid) }.to raise_error Errno::ESRCH
    end
  end

  it "raises an error if the server has stopped", skip_on_windows: true do
    path = "false"
    stub_const("Capybara::Webkit::Server::SERVER_PATH", path)

    expect { start_server }.
      to raise_error(
        Capybara::Webkit::ConnectionError,
        "#{path} failed to start.")
  end

  it "raises an error if the server is not ready", skip_on_windows: true do
    server_path = "sleep 1"
    stub_const("Capybara::Webkit::Server::SERVER_PATH", server_path)
    start_timeout = 0.5
    stub_const(
      "Capybara::Webkit::Server::WEBKIT_SERVER_START_TIMEOUT",
      start_timeout,
    )

    error_string =
      if defined?(::JRUBY_VERSION)
        "#{server_path} failed to start."
      else
        "#{server_path} failed to start after #{start_timeout} seconds."
      end

    expect { start_server }.
      to raise_error(Capybara::Webkit::ConnectionError, error_string)
  end

  it "boots a server to talk to" do
    url = "http://#{@rack_server.host}:#{@rack_server.port}/"
    server = start_server
    socket = connect_to(server)
    socket.puts "Visit"
    socket.puts 1
    socket.puts url.to_s.bytesize
    socket.print url
    socket.gets.should eq "ok\n"
    socket.gets.should eq "0\n"
    socket.puts "Body"
    socket.puts 0
    socket.gets.should eq "ok\n"
    response_length = socket.gets.to_i
    response = socket.read(response_length)
    response.should include("Hey there")
  end

  it "forwards stderr to the given IO object" do
    read_io, write_io = IO.pipe
    server = start_server(stderr: write_io)
    socket = connect_to(server)
    socket.puts "EnableLogging"
    socket.puts 0

    script = "console.log('hello world')"
    socket.puts "Execute"
    socket.puts 1
    socket.puts script.to_s.bytesize
    socket.print script

    expect(read_io).to include_response "\nhello world"
  end

  it "does not forward stderr to nil" do
    IO.should_not_receive(:copy_stream)
    start_server(stderr: nil)
  end

  it "prints a deprecation warning if the stdout option is used" do
    Capybara::Webkit::Server.any_instance.should_receive(:warn)
    start_server(stdout: nil)
  end

  it "does not forward stdout to nil if the stdout option is used" do
    Capybara::Webkit::Server.any_instance.stub(:warn)
    IO.should_not_receive(:copy_stream)
    start_server(stdout: nil)
  end

  it "returns the server port" do
    start_server.port.should be_between 0x400, 0xffff
  end

  it "chooses a new port number for a new connection" do
    start_server.port.should_not == start_server.port
  end

  before(:all) do
    @app = lambda do |_|
      body = "<html><body>Hey there</body></html>"
      [
        200,
        { "Content-Type" => "text/html", "Content-Length" => body.size.to_s },
        [body],
      ]
    end
    @rack_server = Capybara::Server.new(@app)
    @rack_server.boot
  end

  def start_server(options = {})
    Capybara::Webkit::Server.new(options).tap(&:start)
  end

  def connect_to(server)
    TCPSocket.open("127.0.0.1", server.port)
  end

  def eventually
    polling_interval = 0.1
    time_limit = Time.now + 3
    loop do
      begin
        yield
        return
      rescue RSpec::Expectations::ExpectationNotMetError => error
        raise error if Time.now >= time_limit
        sleep polling_interval
      end
    end
  end
end
