require 'socket'
require 'timeout'
require 'thread'

module Capybara::Webkit
  class Connection
    SERVER_PATH = File.expand_path("../../../../bin/webkit_server", __FILE__)
    WEBKIT_SERVER_START_TIMEOUT = 15

    attr_reader :port

    def initialize(options = {})
      @socket_class = options[:socket_class] || TCPSocket
      @stdout = options.has_key?(:stdout) ?  options[:stdout] : $stdout
      @command = options[:command] || SERVER_PATH
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
      forward_stdout_in_background_thread
    end

    def open_pipe
      @pipe = IO.popen(@command)
      @pid = @pipe.pid
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
    end

    def discover_port
      if IO.select([@pipe], nil, nil, WEBKIT_SERVER_START_TIMEOUT)
        @port = ((@pipe.first || '').match(/listening on port: (\d+)/) || [])[1].to_i
      end
    end

    def forward_stdout_in_background_thread
      @stdout_thread = Thread.new do
        Thread.current.abort_on_exception = true
        forward_stdout
      end
    end

    def forward_stdout
      while pipe_readable?
        line = @pipe.readline
        if @stdout
          @stdout.write(line)
          @stdout.flush
        end
      end
    rescue EOFError
    end

    if !defined?(RUBY_ENGINE) || (RUBY_ENGINE == "ruby" && RUBY_VERSION <= "1.8")
      # please note the use of IO::select() here, as it is used specifically to
      # preserve correct signal handling behavior in ruby 1.8.
      # https://github.com/thibaudgg/rb-fsevent/commit/d1a868bf8dc72dbca102bedbadff76c7e6c2dc21
      # https://github.com/thibaudgg/rb-fsevent/blob/1ca42b987596f350ee7b19d8f8210b7b6ae8766b/ext/fsevent/fsevent_watch.c#L171
      def pipe_readable?
        IO.select([@pipe])
      end
    else
      def pipe_readable?
        !@pipe.eof?
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
        @socket.setsockopt(:IPPROTO_TCP, :TCP_NODELAY, 1)
      end
    rescue Errno::ECONNREFUSED
    end
  end
end
