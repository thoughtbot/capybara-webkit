require 'json'

module Capybara::Webkit
  class Browser
    def initialize(connection)
      @connection = connection
    end

    def authenticate(username, password)
      command("Authenticate", username, password)
    end

    def enable_logging
      command "EnableLogging"
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

    def status_code
      command("Status").to_i
    end

    def console_messages
      JSON.parse(command("ConsoleMessages")).map do |message|
        message.inject({}) { |m,(k,v)| m.merge(k.to_sym => v) }
      end
    end

    def error_messages
      console_messages.select do |message|
        message[:message] =~ /Error:/
      end
    end

    def alert_messages
      JSON.parse(command("JavascriptAlertMessages"))
    end

    def confirm_messages
      JSON.parse(command("JavascriptConfirmMessages"))
    end

    def prompt_messages
      JSON.parse(command("JavascriptPromptMessages"))
    end

    def response_headers
      Hash[command("Headers").split("\n").map { |header| header.split(": ") }]
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

    def set_skip_image_loading(skip_image_loading)
      command("SetSkipImageLoading", skip_image_loading)
    end

    def window_focus(selector)
      command("WindowFocus", selector)
    end

    def get_window_handles
      JSON.parse(command('GetWindowHandles'))
    end

    alias_method :window_handles, :get_window_handles

    def get_window_handle
      command('GetWindowHandle')
    end

    alias_method :window_handle, :get_window_handle

    def accept_js_confirms
      command("SetConfirmAction", "Yes")
    end

    def reject_js_confirms
      command("SetConfirmAction", "No")
    end

    def accept_js_prompts
      command("SetPromptAction", "Yes")
    end

    def reject_js_prompts
      command("SetPromptAction", "No")
    end

    def set_prompt_text_to(string)
      command("SetPromptText", string)
    end

    def clear_prompt_text
      command("ClearPromptText")
    end

    def url_blacklist=(black_list)
      command("SetUrlBlacklist", *Array(black_list))
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

    def timeout=(timeout_in_seconds)
      command "SetTimeout", timeout_in_seconds
    end

    def timeout
      command("GetTimeout").to_i
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

    def version
      command("Version")
    end

    private

    def check
      result = @connection.gets
      result.strip! if result

      if result.nil?
        raise NoResponseError, "No response received from the server."
      elsif result != 'ok'
        case response = read_response
        when "timeout"
          raise Timeout::Error, "Request timed out after #{timeout_seconds}"
        else
          raise InvalidResponseError, response
        end
      end

      result
    end

    def timeout_seconds
      seconds = timeout
      if seconds > 1
        "#{seconds} seconds"
      else
        "1 second"
      end
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
