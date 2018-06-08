require 'rspec'
require 'rbconfig'
require 'capybara'

PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..')).freeze

$LOAD_PATH << File.join(PROJECT_ROOT, 'lib')

Dir[File.join(PROJECT_ROOT, 'spec', 'support', '**', '*.rb')].each { |file| require(file) }

require 'capybara/webkit'
$webkit_server = Capybara::Webkit::Server.new
$webkit_connection = Capybara::Webkit::Connection.new(server: $webkit_server)
$webkit_browser = Capybara::Webkit::Browser.new($webkit_connection)

if ENV["DEBUG"]
  $webkit_browser.enable_logging
end

require 'capybara/spec/spec_helper'

Capybara.register_driver :reusable_webkit do |app|
  Capybara::Webkit::Driver.new(app, :browser => $webkit_browser)
end

def has_internet?
  require 'resolv'
  dns_resolver = Resolv::DNS.new
  begin
    dns_resolver.getaddress("example.com")
    true
  rescue Resolv::ResolvError
    false
  end
end

RSpec.configure do |c|
  Capybara::SpecHelper.configure(c)

  c.filter_run_excluding :skip_on_windows => !(RbConfig::CONFIG['host_os'] =~ /mingw32/).nil?
  c.filter_run_excluding :skip_on_jruby => !defined?(::JRUBY_VERSION).nil?
  c.filter_run_excluding :selenium_compatibility => (Capybara::VERSION =~ /^2\.4\./).nil?
  c.filter_run_excluding :skip_if_offline => !has_internet?

  #Check for QT version is 4 to skip QT5 required specs
  #This should be removed once support for QT4 is dropped
  require 'capybara_webkit_builder'
  c.filter_run_excluding :skip_on_qt4 => !(%x(#{CapybaraWebkitBuilder.qmake_bin} -v).match(/Using Qt version 4/)).nil?

  c.filter_run_excluding :full_description => lambda { |description, metadata|
    patterns = [
      # Accessing unattached nodes is allowed when reload is disabled - Legacy behavior
      /^Capybara::Session webkit node #reload without automatic reload should not automatically reload/,
      # QtWebkit doesn't support datalist
      /^Capybara::Session webkit #select input with datalist should select an option/,
      # We focus the next window instead of failing when closing windows.
      /^Capybara::Session webkit Capybara::Window\s*#close.*no_such_window_error/,
      # QtWebkit doesn't support HTTP 308 response status
      /^Capybara::Session webkit #click_button should follow permanent redirects that maintain method/,
    ]
    # These tests were implemented in a non-compatible manner in Capybara < 2.12.0 (outerWidth, outerHeight)
    if Gem::Version.new(Capybara::VERSION) < Gem::Version.new("2.12.0")
      patterns << /Capybara::Session webkit Capybara::Window\s*#(size|resize_to|maximize)/ <<
                  /Capybara::Session webkit node\s*#set should allow me to change the contents of a contenteditable elements child/
    end
    patterns.any? { |pattern| description =~ pattern }
  }

  c.filter_run :focus unless ENV["TRAVIS"]
  c.run_all_when_everything_filtered = true
end

def with_env_vars(vars)
  old_env_variables = {}
  vars.each do |key, value|
    old_env_variables[key] = ENV[key]
    ENV[key] = value
  end

  yield

  old_env_variables.each do |key, value|
    ENV[key] = value
  end
end
