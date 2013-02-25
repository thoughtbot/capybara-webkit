require "capybara"
require "capybara/webkit/version"
require "capybara/webkit/node"
require "capybara/webkit/connection"
require "capybara/webkit/browser"
require "capybara/webkit/socket_debugger"
require "capybara/webkit/cookie_jar"
require "capybara/webkit/errors"

module Capybara::Webkit
  class Driver
    attr_reader :browser

    def initialize(app, options={})
      @app = app
      @options = options
      @browser = options[:browser] || Browser.new(Connection.new(options))
    end

    def enable_logging
      browser.enable_logging
    end

    def current_url
      browser.current_url
    end

    def visit(path)
      browser.visit(path)
    end

    def find_xpath(xpath)
      browser.find_xpath(xpath).map { |native| Node.new(self, native) }
    end

    alias_method :find, :find_xpath

    def find_css(selector)
      browser.find_css(selector).map { |native| Node.new(self, native) }
    end

    def html
      browser.body
    end

    def header(key, value)
      browser.header(key, value)
    end

    def title
      browser.title
    end

    def execute_script(script)
      value = browser.execute_script script
      value.empty? ? nil : value
    end

    def evaluate_script(script)
      browser.evaluate_script script
    end

    def console_messages
      browser.console_messages
    end

    def error_messages
      browser.error_messages
    end

    def alert_messages
      browser.alert_messages
    end

    def confirm_messages
      browser.confirm_messages
    end

    def prompt_messages
      browser.prompt_messages
    end

    def response_headers
      browser.response_headers
    end

    def status_code
      browser.status_code
    end

    def resize_window(width, height)
      browser.resize_window(width, height)
    end

    def within_frame(selector)
      browser.frame_focus(selector)
      begin
        yield
      ensure
        browser.frame_focus
      end
    end

    def within_window(selector)
      current_window = window_handle
      browser.window_focus(selector)
      begin
        yield
      ensure
        browser.window_focus(current_window)
      end
    end

    def window_handles
      browser.get_window_handles
    end

    def window_handle
      browser.get_window_handle
    end

    def accept_js_confirms!
      browser.accept_js_confirms
    end

    def dismiss_js_confirms!
      browser.reject_js_confirms
    end

    def accept_js_prompts!
      browser.accept_js_prompts
    end

    def dismiss_js_prompts!
      browser.reject_js_prompts
    end

    def js_prompt_input=(value)
      if value.nil?
        browser.clear_prompt_text
      else
        browser.set_prompt_text_to(value)
      end
    end

    def wait?
      true
    end

    def needs_server?
      true
    end

    def reset!
      browser.reset!
    end

    def has_shortcircuit_timeout?
      false
    end

    def save_screenshot(path, options={})
      options[:width]  ||= 1000
      options[:height] ||= 10

      browser.render path, options[:width], options[:height]
    end

    def cookies
      @cookie_jar ||= CookieJar.new(browser)
    end

    def invalid_element_errors
      [Capybara::Webkit::ClickFailed]
    end

    def version
      [
        "Capybara: #{Capybara::VERSION}",
        "capybara-webkit: #{Capybara::Driver::Webkit::VERSION}",
        browser.version
      ].join("\n")
    end
  end
end
