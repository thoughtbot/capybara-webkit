require 'socket'
require 'timeout'
require 'thread'
require 'open3'

module Capybara::Webkit
  class Connection
    SERVER_PATH = File.expand_path("../../../../bin/webkit_server", __FILE__)
    WEBKIT_SERVER_START_TIMEOUT = 15

    attr_reader :port, :pid

    def initialize(options = {})
      @socket = nil
      @socket_class = options[:socket_class] || TCPSocket
      if options.has_key?(:stderr)
        @output_target = options[:stderr]
      elsif options.has_key?(:stdout)
        warn '[DEPRECATION] The Capybara::Webkit::Connection `stdout` option ' \
          'is deprecated. Please use `stderr` instead.'
        @output_target = options[:stdout]
      else
        @output_target = $stderr
      end
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
      discover_pid
      forward_output_in_background_thread
    end

    def open_pipe
      @pipe_stdin, @pipe_stdout, @pipe_stderr, @wait_thr = Open3.popen3(SERVER_PATH)
    end

    def discover_port
      if IO.select([@pipe_stdout], nil, nil, WEBKIT_SERVER_START_TIMEOUT)
        @port = ((@pipe_stdout.first || '').match(/listening on port: (\d+)/) || [])[1].to_i
      end
    end

    def discover_pid
      @pid = @wait_thr[:pid]
    end

    def forward_output_in_background_thread
      Thread.new do
        Thread.current.abort_on_exception = true
        IO.copy_stream(@pipe_stderr, @output_target) if @output_target
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
