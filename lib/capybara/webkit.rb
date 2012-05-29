require "capybara"
require "capybara/driver/webkit"

Capybara.register_driver :webkit do |app|
  Capybara::Driver::Webkit.new(app)
end

Capybara.register_driver :webkit_debug do |app|
  connection = Capybara::Driver::Webkit::Connection.new(
    :socket_class => Capybara::Driver::Webkit::SocketDebugger)
  browser = Capybara::Driver::Webkit::Browser.new(connection)
  Capybara::Driver::Webkit.new(app, :browser => browser)
end
