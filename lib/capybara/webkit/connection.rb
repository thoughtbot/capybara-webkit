require 'socket'
require 'timeout'
require 'thread'

module Capybara::Webkit
  class Connection
    def initialize(options = {})
      @socket = nil
      if options.has_key?(:socket_class)
        warn '[DEPRECATION] The Capybara::Webkit::Connection `socket_class` ' \
          'option is deprecated without replacement.'
        @socket_class = options[:socket_class]
      else
        @socket_class = TCPSocket
      end
      @server = options[:server]
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
      response = ""
      until response.match(/\n/) do
        response += read(1)
      end
      response
    end

    def read(length)
      response = ""
      begin
        while response.length < length do
          response += @socket.read_nonblock(length - response.length)
        end
      rescue IO::WaitReadable
        Thread.new { IO.select([@socket]) }.join
        retry
      end
      response
    end

    def restart
      @socket = nil
      start_server
      connect
    end

    def port
      @server.port
    end

    def pid
      @server.pid
    end

    private

    def start_server
      @server.start
    end

    def connect
      Timeout.timeout(5) do
        while @socket.nil?
          attempt_connect
        end
      end
    end

    def attempt_connect
      @socket = @socket_class.open("127.0.0.1", port)
      if defined?(Socket::TCP_NODELAY)
        @socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, true)
      end
    rescue Errno::ECONNREFUSED
    end
  end
end
