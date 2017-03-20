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

if ENV['DEBUG']
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

  # We can't support outerWidth and outerHeight without a visible window. Only affects Capybara < 2.12.0
  # We focus the next window instead of failing when closing windows.
  # Accessing unattached nodes is allowed when reload is disabled - Legacy behavior
  # Node#send_keys does not support modifiers and only supports a subset of special keys
  c.filter_run_excluding :full_description => lambda { |description, metadata|
    (description =~ /Capybara::Session webkit node #reload without automatic reload should not automatically reload/ ||
     if Gem::Version.new(Capybara::VERSION) < Gem::Version.new("2.12.0")
       description =~ /Capybara::Session webkit Capybara::Window\s*#(size|resize_to|maximize|close.*no_such_window_error)/ ||
       description =~ /Capybara::Session webkit node\s*#set should allow me to change the contents of a contenteditable elements child/
     else
       description =~ /Capybara::Session webkit Capybara::Window\s*#close.*no_such_window_error/
     end
    )
  }
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
