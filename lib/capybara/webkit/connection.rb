require 'socket'
require 'timeout'
require 'thread'
require 'open3'

module Capybara::Webkit
  class Connection
    SERVER_PATH = File.expand_path("../../../../bin/webkit_server", __FILE__)

    attr_reader :port

    def initialize(options = {})
      if options.has_key?(:stderr)
        @output_target = options[:stderr]
      elsif options.has_key?(:stdout)
        warn "[DEPRECATION] The `stdout` option is deprecated.  Please use `stderr` instead."
        @output_target = options[:stdout]
      else
        @output_target = $stderr
      end
      start_server
    end

    def puts(string)
      @pipe_stdin.puts string
    end

    def print(string)
      @pipe_stdin.print string
    end

    def gets
      @pipe_stdout.gets
    end

    def read(length)
      @pipe_stdout.read(length)
    end

    private

    def start_server
      open_pipe
      check_ready
      forward_output_in_background_thread
    end

    def open_pipe
      @pipe_stdin, @pipe_stdout, @pipe_stderr, wait_thr = Open3.popen3(SERVER_PATH)
      @pid = wait_thr[:pid]
      register_shutdown_hook
    end

    def check_ready
      result = @pipe_stdout.gets
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

    def forward_output_in_background_thread
      Thread.new do
        Thread.current.abort_on_exception = true
        IO.copy_stream(@pipe_stderr, @output_target) if @output_target
      end
    end
  end
end
