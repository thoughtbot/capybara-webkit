require 'json'

class Capybara::Driver::Webkit
  class Browser
    def initialize(connection)
      @connection = connection
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

    def body
      command("Body")
    end

    def source
      command("Source")
    end

    def status_code
      command("Status").to_i
    end

    def console_messages
      command("ConsoleMessages").split("\n").map do |messages|
        parts = messages.split("|", 3)
        { :source => parts.first, :line_number => Integer(parts[1]), :message => parts.last }
      end
    end

    def error_messages
      console_messages.select do |message|
        message[:message] =~ /Error:/
      end
    end

    def response_headers
      Hash[command("Headers").split("\n").map { |header| header.split(": ") }]
    end

    def url
      command("Url")
    end

    def requested_url
      command("RequestedUrl")
    end

    def current_url
      command("CurrentUrl")
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

    def ignore_ssl_errors
      command("IgnoreSslErrors")
    end

    def command(name, *args)
      @connection.puts name
      @connection.puts args.size
      args.each do |arg|
        @connection.puts arg.to_s.bytesize
        @connection.print arg.to_s
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

    def set_cookie(cookie)
      command "SetCookie", cookie
    end

    def clear_cookies
      command "ClearCookies"
    end

    def get_cookies
      command("GetCookies").lines.map{ |line| line.strip }.select{ |line| !line.empty? }
    end

    def set_proxy(options = {})
      options = default_proxy_options.merge(options)
      command("SetProxy", options[:host], options[:port], options[:user], options[:pass])
    end

    def clear_proxy
      command("SetProxy")
    end

    def resize_window(width, height)
      command("ResizeWindow", width.to_i, height.to_i)
    end

    private

    def check
      result = @connection.gets
      result.strip! if result

      if result.nil?
        raise WebkitNoResponseError, "No response received from the server."
      elsif result != 'ok' 
        raise WebkitInvalidResponseError, read_response
      end

      result
    end

    def read_response
      response_length = @connection.gets.to_i
      if response_length > 0
        response = @connection.read(response_length)
        response.force_encoding("UTF-8") if response.respond_to?(:force_encoding)
        response
      else
        ""
      end
    end

    def default_proxy_options
      {
        :host => "localhost",
        :port => "0",
        :user => "",
        :pass => ""
      }
    end
  end
end
