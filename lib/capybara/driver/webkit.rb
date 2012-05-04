require "capybara"
require "capybara/driver/webkit/version"
require "capybara/driver/webkit/node"
require "capybara/driver/webkit/connection"
require "capybara/driver/webkit/browser"
require "capybara/driver/webkit/socket_debugger"
require "capybara/driver/webkit/cookie_jar"

class Capybara::Driver::Webkit
  class WebkitInvalidResponseError < StandardError
  end

  class WebkitNoResponseError < StandardError
  end

  class NodeNotAttachedError < Capybara::ElementNotFound
  end

  attr_reader :browser

  def initialize(app, options={})
    @app = app
    @options = options
    @rack_server = Capybara::Server.new(@app)
    @rack_server.boot if Capybara.run_server
    @browser = options[:browser] || Browser.new(Connection.new(options))
    @browser.ignore_ssl_errors if options[:ignore_ssl_errors]
  end

  def current_url
    browser.current_url
  end

  def requested_url
    browser.requested_url
  end

  def visit(path)
    browser.visit(url(path))
  end

  def find(query)
    browser.find(query).map { |native| Node.new(self, native) }
  end

  def source
    browser.source
  end

  def body
    browser.body
  end

  def header(key, value)
    browser.header(key, value)
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

  def response_headers
    browser.response_headers
  end

  def status_code
    browser.status_code
  end

  def resize_window(width, height)
    browser.resize_window(width, height)
  end

  def within_frame(frame_id_or_index)
    browser.frame_focus(frame_id_or_index)
    begin
      yield
    ensure
      browser.frame_focus
    end
  end

  def within_window(handle)
    raise Capybara::NotSupportedByDriverError
  end

  def wait?
    true
  end

  def wait_until(*args)
  end

  def reset!
    browser.reset!
  end

  def has_shortcircuit_timeout?
    false
  end

  def render(path, options={})
    options[:width]  ||= 1000
    options[:height] ||= 10

    browser.render path, options[:width], options[:height]
  end

  def server_port
    @rack_server.port
  end

  def cookies
    @cookie_jar ||= CookieJar.new(browser)
  end

  private

  def url(path)
    @rack_server.url(path)
  end
end

