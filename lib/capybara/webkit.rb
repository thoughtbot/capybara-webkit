require "capybara"
require "capybara/driver/webkit"

Capybara.register_driver :webkit do |app|
  Capybara::Driver::Webkit.new(app)
end

Capybara.register_driver :webkit_debug do |app|
  driver = Capybara::Driver::Webkit.new(app)
  driver.enable_logging
  driver
end
