require 'socket'
require 'timeout'
require 'thread'
require 'open3'

module Capybara::Webkit
  class Connection
    SERVER_PATH = File.expand_path("../../../../bin/webkit_server", __FILE__)
    WEBKIT_SERVER_START_TIMEOUT = 15

    attr_reader :port

    def initialize(options = {})
      @socket_class = options[:socket_class] || TCPSocket
      @output_target = options.has_key?(:stdout) ? options[:stdout] : $stdout
      start_server
      connect
    end

    def puts(string)
      @socket.puts string
    end

    def print(string)
      @socket.print string
    end

    def gets
      @socket.gets
    end

    def read(length)
      @socket.read(length)
    end

    private

    def start_server
      open_pipe
      discover_port
      forward_output_in_background_thread
    end

    def open_pipe
      _, @pipe_stdout, @pipe_stderr, wait_thr = Open3.popen3(SERVER_PATH)
      @pid = wait_thr[:pid]
      register_shutdown_hook
    end

    def register_shutdown_hook
      @owner_pid = Process.pid
      at_exit do
        if Process.pid == @owner_pid
          kill_process
        end
      end
    end

    def kill_process
      if RUBY_PLATFORM =~ /mingw32/
        Process.kill(9, @pid)
      else
        Process.kill("INT", @pid)
      end
    rescue Errno::ESRCH
      # This just means that the webkit_server process has already ended
    end

    def discover_port
      if IO.select([@pipe_stdout], nil, nil, WEBKIT_SERVER_START_TIMEOUT)
        @port = ((@pipe_stdout.first || '').match(/listening on port: (\d+)/) || [])[1].to_i
      end
    end

    def forward_output_in_background_thread
      Thread.new do
        Thread.current.abort_on_exception = true
        IO.copy_stream(@pipe_stdout, @output_target)
      end
      Thread.new do
        Thread.current.abort_on_exception = true
        IO.copy_stream(@pipe_stderr, @output_target)
      end
    end

    def connect
      Timeout.timeout(5) do
        while @socket.nil?
          attempt_connect
        end
      end
    end

    def attempt_connect
      @socket = @socket_class.open("127.0.0.1", @port)
      if defined?(Socket::TCP_NODELAY)
        @socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, true)
      end
    rescue Errno::ECONNREFUSED
    end
  end
end
