require "open3"
require "thread"

module Capybara
  module Webkit
    class Server
      SERVER_PATH = File.expand_path("../../../../bin/webkit_server", __FILE__)
      WEBKIT_SERVER_START_TIMEOUT = 15

      attr_reader :port, :pid

      def initialize(options = {})
        if options.has_key?(:stderr)
          @output_target = options[:stderr]
        elsif options.has_key?(:stdout)
          warn "[DEPRECATION] The Capybara::Webkit::Connection `stdout` " \
            "option is deprecated. Please use `stderr` instead."
          @output_target = options[:stdout]
        else
          @output_target = $stderr
        end
      end

      def start
        open_pipe
        discover_port
        discover_pid
        forward_output_in_background_thread
      end

      private

      def open_pipe
        @pipe_stdin,
          @pipe_stdout,
          @pipe_stderr,
          @wait_thr = Open3.popen3(SERVER_PATH)
      end

      def discover_port
        if IO.select([@pipe_stdout], nil, nil, WEBKIT_SERVER_START_TIMEOUT)
          @port = parse_port(@pipe_stdout.first)
        else
          raise(
            ConnectionError,
            "#{SERVER_PATH} failed to start after " \
            "#{WEBKIT_SERVER_START_TIMEOUT} seconds.",
          )
        end
      end

      def parse_port(line)
        if match = line.to_s.match(/listening on port: (\d+)/)
          match[1].to_i
        else
          raise ConnectionError, "#{SERVER_PATH} failed to start."
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
    end
  end
end
