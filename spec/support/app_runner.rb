# Boots a single Capybara::Server for a Rack application that delegates to another, singleton Rack
# application that can be configured for each spec. Also configures Capybara to use that server.

module AppRunner
  class << self
    attr_accessor :app, :app_host
  end

  def self.boot
    app_container = lambda { |env| AppRunner.app.call(env) }
    server = Capybara::Server.new(app_container)
    server.boot
    self.app_host = "http://127.0.0.1:#{server.port}"
  end

  def self.reset
    self.app = lambda do |env|
      [200, { 'Content-Type' => 'html', 'Content-Length' => 0 }, []]
    end
  end

  def run_application(&app)
    AppRunner.app = app
  end

  def driver_for_app(&app)
    run_application(&app)
    Capybara::Webkit::Driver.new(app, :browser => $webkit_browser)
  end

  def self.included(example_group)
    example_group.class_eval do
      before { AppRunner.reset }

      around do |example|
        Capybara.run_server = false
        Capybara.app_host = AppRunner.app_host
        begin
          example.run
        ensure
          Capybara.run_server = true
          Capybara.app_host = nil
        end
      end
    end
  end
end

AppRunner.boot
