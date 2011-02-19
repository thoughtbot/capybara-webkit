require "capybara"
require "capybara/driver/webkit"

Capybara.register_driver :webkit do |app|
  Capybara::Driver::Webkit.new(app)
end

