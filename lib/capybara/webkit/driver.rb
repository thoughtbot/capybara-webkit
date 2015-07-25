require "capybara"
require "capybara/webkit/version"
require "capybara/webkit/node"
require "capybara/webkit/connection"
require "capybara/webkit/browser"
require "capybara/webkit/cookie_jar"
require "capybara/webkit/errors"

module Capybara::Webkit
  class Driver < Capybara::Driver::Base
    def initialize(app, options={})
      @app = app
      @options = options
      @browser = options[:browser] || Browser.new(Connection.new(options))
      apply_options
    end

    def current_url
      @browser.current_url
    end

    def visit(path)
      @browser.visit(path)
    end

    def find_xpath(xpath)
      @browser.
        find_xpath(xpath).
        map { |native| Node.new(self, native, @browser) }
    end

    alias_method :find, :find_xpath

    def find_css(selector)
      @browser.
        find_css(selector).
        map { |native| Node.new(self, native, @browser) }
    end

    def html
      @browser.body
    end

    def header(key, value)
      @browser.header(key, value)
    end

    def title
      @browser.title
    end

    def execute_script(script)
      value = @browser.execute_script script
      value.empty? ? nil : value
    end

    def evaluate_script(script)
      @browser.evaluate_script script
    end

    def console_messages
      @browser.console_messages
    end

    def error_messages
      @browser.error_messages
    end

    def response_headers
      @browser.response_headers
    end

    def status_code
      @browser.status_code
    end

    def resize_window_to(handle, width, height)
      @browser.window_resize(handle, width, height)
    end

    def window_size(handle)
      @browser.window_size(handle)
    end

    def within_frame(selector)
      @browser.frame_focus(selector)
      begin
        yield
      ensure
        @browser.frame_focus
      end
    end

    def within_window(selector)
      current_window = current_window_handle
      switch_to_window(selector)
      begin
        yield
      ensure
        @browser.window_focus(current_window)
      end
    end

    def switch_to_window(selector)
      @browser.window_focus(selector)
    end

    def window_handles
      @browser.get_window_handles
    end

    def current_window_handle
      @browser.get_window_handle
    end

    def open_new_window
      @browser.window_open
    end

    def close_window(selector)
      @browser.window_close(selector)
    end

    def maximize_window(selector)
      @browser.window_maximize(selector)
    end

    def go_back
      @browser.go_back
    end

    def go_forward
      @browser.go_forward
    end

    def accept_modal(type, options={})
      options = modal_action_options_for_browser(options)

      case type
      when :confirm
        id = @browser.accept_confirm(options)
      when :prompt
        id = @browser.accept_prompt(options)
      else
        id = @browser.accept_alert(options)
      end

      yield

      find_modal(type, id, options)
    end

    def dismiss_modal(type, options={})
      options = modal_action_options_for_browser(options)

      case type
      when :confirm
        id = @browser.reject_confirm(options)
      else
        id = @browser.reject_prompt(options)
      end

      yield

      find_modal(type, id, options)
    end

    def wait?
      true
    end

    def needs_server?
      true
    end

    def reset!
      @browser.reset!
      apply_options
    end

    def has_shortcircuit_timeout?
      false
    end

    def save_screenshot(path, options={})
      options[:width]  ||= 1000
      options[:height] ||= 10

      @browser.render path, options[:width], options[:height]
    end

    def cookies
      @cookie_jar ||= CookieJar.new(@browser)
    end

    def set_cookie(cookie)
      @browser.set_cookie(cookie)
    end

    def clear_cookies
      @browser.clear_cookies
    end

    def invalid_element_errors
      [Capybara::Webkit::ClickFailed]
    end

    def no_such_window_error
      Capybara::Webkit::NoSuchWindowError
    end

    def version
      [
        "Capybara: #{Capybara::VERSION}",
        "capybara-webkit: #{Capybara::Driver::Webkit::VERSION}",
        @browser.version
      ].join("\n")
    end

    def authenticate(username, password)
      @browser.authenticate(username, password)
    end

    private

    def modal_action_options_for_browser(options)
      if options[:text].is_a?(Regexp)
        options.merge(text: options[:text].source)
      else
        options.merge(text: Regexp.escape(options[:text].to_s))
      end.merge(original_text: options[:text])
    end

    def find_modal(type, id, options)
      Timeout::timeout(options[:wait] || Capybara.default_wait_time) do
        @browser.find_modal(id)
      end
    rescue ModalNotFound
      raise Capybara::ModalNotFound,
        "Unable to find modal dialog#{" with #{options[:original_text]}" if options[:original_text]}"
    rescue Timeout::Error
      raise Capybara::ModalNotFound,
        "Timed out waiting for modal dialog#{" with #{options[:original_text]}" if options[:original_text]}"
    end

    def apply_options
      if @options[:debug]
        @browser.enable_logging
      end

      if @options[:block_unknown_urls]
        @browser.block_unknown_urls
      end

      if @options[:ignore_ssl_errors]
        @browser.ignore_ssl_errors
      end

      if @options[:skip_image_loading]
        @browser.set_skip_image_loading(true)
      end

      if @options[:proxy]
        @browser.set_proxy(@options[:proxy])
      end

      if @options[:timeout]
        @browser.timeout = @options[:timeout]
      end

      Array(@options[:allowed_urls]).each { |url| @browser.allow_url(url) }
      Array(@options[:blocked_urls]).each { |url| @browser.block_url(url) }
    end
  end
end
