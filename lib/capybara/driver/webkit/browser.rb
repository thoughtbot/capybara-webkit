require 'socket'

class Capybara::Driver::Webkit
  class Browser
    def initialize
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

    def command(name, *args)
      @socket.puts name
      args.each { |arg| @socket.puts arg }
      check
      read_response
    end

    private

    def start_server
      @pid = fork { exec("webkit_server") }
      at_exit { Process.kill("INT", @pid) }
    end

    def connect
      Capybara.timeout(5) do
        attempt_connect
        !@socket.nil?
      end
    end

    def attempt_connect
      @socket = TCPSocket.open("localhost", 9200)
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
      @socket.read(response_length)
    end
  end
end
