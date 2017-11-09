require "spec_helper"
require "capybara/webkit/server"

describe Capybara::Webkit::Connection do
  it "ensures the process ends when the parent process ends", skip_on_windows: true, skip_on_jruby: true do
    sleep 1 # Without this sleep popen3 hangs on OSX when running the tests - not really sure why
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
    expect(webkit_pid).to be > 1
    read_io.close
    Process.kill(9, fork_pid)

    eventually do
      expect { Process.getpgid(webkit_pid) }.to raise_error Errno::ESRCH
    end
  end

  it "shouldn't output extraneous warnings when exiting", skip_on_windows: true do
    output_str, status = Open3.capture2e("rspec spec/fixtures/exit_text.rb")
    expect(status.exitstatus).to eq(0)
    expect(output_str).not_to include("AsynchronousCloseException")
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
    server_path = File.expand_path(File.join(__FILE__, "..", "fixtures", "fake_server.sh"))
    stub_const("Capybara::Webkit::Server::SERVER_PATH", server_path)
    start_timeout = 0.5
    stub_const(
      "Capybara::Webkit::Server::WEBKIT_SERVER_START_TIMEOUT",
      start_timeout,
    )

    error_string =
      "#{server_path} failed to start after #{start_timeout} seconds."

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
    expect(socket.gets).to eq "ok\n"
    expect(socket.gets).to eq "0\n"
    socket.puts "Body"
    socket.puts 0
    expect(socket.gets).to eq "ok\n"
    response_length = socket.gets.to_i
    response = socket.read(response_length)
    expect(response).to include("Hey there")
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

    expect(read_io).to include_response /\n\d{2}:\d{2}:\d{2}\.\d{3} hello world/
  end

  it "does not forward stderr to nil" do
    expect(IO).not_to receive(:copy_stream)
    start_server(stderr: nil)
  end

  it "prints a deprecation warning if the stdout option is used" do
    expect_any_instance_of(Capybara::Webkit::Server).to receive(:warn)
    start_server(stdout: nil)
  end

  it "does not forward stdout to nil if the stdout option is used" do
    allow_any_instance_of(Capybara::Webkit::Server).to receive(:warn)
    expect(IO).not_to receive(:copy_stream)
    start_server(stdout: nil)
  end

  it "returns the server port" do
    expect(start_server.port).to be_between 0x400, 0xffff
  end

  it "chooses a new port number for a new connection" do
    expect(start_server.port).not_to eq start_server.port
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
