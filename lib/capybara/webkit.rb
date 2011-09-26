require "capybara"
require "capybara/driver/webkit"

Capybara.register_driver :webkit do |app|
  Capybara::Driver::Webkit.new(app)
end

Capybara.register_driver :webkit_debug do |app|
  browser = Capybara::Driver::Webkit::Browser.new(:socket_class => Capybara::Driver::Webkit::SocketDebugger)
  Capybara::Driver::Webkit.new(app, :browser => browser)
end
