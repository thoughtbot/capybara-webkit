require 'socket'
require 'capybara/util/timeout'
require 'json'

class Capybara::Driver::Webkit
  class Browser
    attr :server_port

    def initialize(options = {})
      @socket_class = options[:socket_class] || TCPSocket
      start_server
      connect
    end

    def visit(url)
      command "Visit", url
    end

    def header(key, value)
      command("Header", key, value)
    end

    def find(query)
      command("Find", query).split(",")
    end

    def reset!
      command("Reset")
    end

    def source
      command("Source")
    end

    def url
      command("Url")
    end

    def frame_focus(frame_id_or_index=nil)
      if frame_id_or_index.is_a? Fixnum
        command("FrameFocus", "", frame_id_or_index.to_s)
      elsif frame_id_or_index
        command("FrameFocus", frame_id_or_index)
      else
        command("FrameFocus")
      end
    end

    def command(name, *args)
      @socket.puts name
      @socket.puts args.size
      args.each do |arg|
        @socket.puts arg.to_s.bytesize
        @socket.print arg.to_s
      end
      check
      read_response
    end

    def evaluate_script(script)
      json = command('Evaluate', script)
      JSON.parse("[#{json}]").first
    end

    def execute_script(script)
      command('Execute', script)
    end

    def render(path, width, height)
      command "Render", path, width, height
    end

    private

    def start_server
      read_pipe, write_pipe = fork_server
      @server_port = discover_server_port(read_pipe)
    end

    def fork_server
      server_path = File.expand_path("../../../../../bin/webkit_server", __FILE__)

      read_pipe, write_pipe = IO.pipe
      @pid = fork do
        $stdout.reopen write_pipe
        read_pipe.close
        exec(server_path)
      end
      at_exit { Process.kill("INT", @pid) }

      write_pipe.close
      [read_pipe, write_pipe]
    end

    def discover_server_port(read_pipe)
      return unless IO.select([read_pipe], nil, nil, 10)
      ((read_pipe.first || '').match(/listening on port: (\d+)/) || [])[1].to_i
    end

    def connect
      Capybara.timeout(5) do
        attempt_connect
        !@socket.nil?
      end
    end

    def attempt_connect
      @socket = @socket_class.open("localhost", @server_port)
    rescue Errno::ECONNREFUSED
    end

    def check
      result = @socket.gets
      result.strip! if result

      if result.nil?
        raise WebkitNoResponseError, "No response received from the server."
      elsif result != 'ok' 
        raise WebkitInvalidResponseError, read_response
      end

      result
    end

    def read_response
      response_length = @socket.gets.to_i
      response = @socket.read(response_length)
      response.force_encoding("UTF-8") if response.respond_to?(:force_encoding)
      response
    end
  end
end
