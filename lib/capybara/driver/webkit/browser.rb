require 'socket'
require 'capybara/util/timeout'
require 'json'

class Capybara::Driver::Webkit
  class Browser
    def initialize(options = {})
      @socket_class = options[:socket_class] || TCPSocket
      start_server
      connect
    end

    def visit(url)
      command "Visit", url
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
        @socket.print arg
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

    private

    def start_server
      server_path = File.expand_path("../../../../../bin/webkit_server", __FILE__)
      @pid = fork { exec(server_path) }
      at_exit { Process.kill("INT", @pid) }
    end

    def connect
      Capybara.timeout(5) do
        attempt_connect
        !@socket.nil?
      end
    end

    def attempt_connect
      @socket = @socket_class.open("localhost", 9200)
    rescue Errno::ECONNREFUSED
    end

    def check
      result = @socket.gets.strip

      unless result == 'ok'
        raise WebkitError, read_response
      end
    end

    def read_response
      response_length = @socket.gets.to_i
      s = @socket.read(response_length)
      s.force_encoding("UTF-8")
      s
    end
  end
end
