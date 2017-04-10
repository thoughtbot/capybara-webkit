require "capybara"

module Capybara
  module Webkit
    def self.configure(&block)
      Capybara::Webkit::Configuration.modify(&block)
    end
  end
end

require "capybara/webkit/driver"
require "capybara/webkit/configuration"

Capybara.register_driver :webkit do |app|
  Capybara::Webkit::Driver.new(app, Capybara::Webkit::Configuration.to_hash)
end

Capybara.register_driver :webkit_ignore_ssl do |app|
  browser = Capybara::Driver::Webkit::Browser.new(:ignore_ssl_errors => true)
  Capybara::Driver::Webkit.new(app, :browser => browser)
end

Capybara.register_driver :webkit_debug do |app|
  warn "[DEPRECATION] The webkit_debug driver is deprecated. " \
    "Please use Capybara::Webkit.configure instead:\n\n" \
    "  Capybara::Webkit.configure do |config|\n" \
    "    config.debug = true\n" \
    "  end\n\n" \
    "This option is global and can be configured once" \
    " (not in a `before` or `setup` block)."

  Capybara::Webkit::Driver.new(
    app,
    Capybara::Webkit::Configuration.to_hash.merge(debug: true)
  )
end
