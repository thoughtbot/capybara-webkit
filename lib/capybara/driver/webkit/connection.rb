require 'socket'
require 'timeout'
require 'thread'

class Capybara::Driver::Webkit
  class Connection
    WEBKIT_SERVER_START_TIMEOUT = 15

    attr_reader :port

    def initialize(options = {})
      @socket_class = options[:socket_class] || TCPSocket
      @stdout       = options.has_key?(:stdout) ?
                        options[:stdout] :
                        $stdout
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
      pipe = fork_server
      @port = discover_port(pipe)
      @stdout_thread = Thread.new do
        Thread.current.abort_on_exception = true
        forward_stdout(pipe)
      end
    end

    def fork_server
      server_path = File.expand_path("../../../../../bin/webkit_server", __FILE__)
      pipe, @pid = server_pipe_and_pid(server_path)
      register_shutdown_hook
      pipe
    end

    def kill_process(pid)
      if RUBY_PLATFORM =~ /mingw32/
        Process.kill(9, pid)
      else
        Process.kill("INT", pid)
      end
    end

    def register_shutdown_hook
      @owner_pid = Process.pid
      at_exit do
        if Process.pid == @owner_pid
          kill_process(@pid)
        end
      end
    end

    def server_pipe_and_pid(server_path)
      cmdline = [server_path]
      pipe = IO.popen(cmdline.join(" "))
      [pipe, pipe.pid]
    end

    def discover_port(read_pipe)
      return unless IO.select([read_pipe], nil, nil, WEBKIT_SERVER_START_TIMEOUT)
      ((read_pipe.first || '').match(/listening on port: (\d+)/) || [])[1].to_i
    end

    def forward_stdout(pipe)
      while pipe_readable?(pipe)
        line = pipe.readline
        if @stdout
          @stdout.write(line)
          @stdout.flush
        end
      end
    rescue EOFError
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
    rescue Errno::ECONNREFUSED
    end

    if !defined?(RUBY_ENGINE) || (RUBY_ENGINE == "ruby" && RUBY_VERSION <= "1.8")
      # please note the use of IO::select() here, as it is used specifically to
      # preserve correct signal handling behavior in ruby 1.8.
      # https://github.com/thibaudgg/rb-fsevent/commit/d1a868bf8dc72dbca102bedbadff76c7e6c2dc21
      # https://github.com/thibaudgg/rb-fsevent/blob/1ca42b987596f350ee7b19d8f8210b7b6ae8766b/ext/fsevent/fsevent_watch.c#L171
      def pipe_readable?(pipe)
        IO.select([pipe])
      end
    else
      def pipe_readable?(pipe)
        !pipe.eof?
      end
    end
  end
end
