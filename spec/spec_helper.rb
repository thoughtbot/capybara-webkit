require 'rspec'
require 'rspec/autorun'
require 'rbconfig'
require 'capybara'

PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..')).freeze

$LOAD_PATH << File.join(PROJECT_ROOT, 'lib')

Dir[File.join(PROJECT_ROOT, 'spec', 'support', '**', '*.rb')].each { |file| require(file) }

require 'capybara/webkit'
$webkit_connection = Capybara::Webkit::Connection.new(:socket_class => TCPSocket)
$webkit_browser = Capybara::Webkit::Browser.new($webkit_connection)

if ENV['DEBUG']
  $webkit_browser.enable_logging
end

require 'capybara/spec/spec_helper'

Capybara.register_driver :reusable_webkit do |app|
  Capybara::Webkit::Driver.new(app, :browser => $webkit_browser)
end

RSpec.configure do |c|
  Capybara::SpecHelper.configure(c)

  c.filter_run_excluding :skip_on_windows => !(RbConfig::CONFIG['host_os'] =~ /mingw32/).nil?
  c.filter_run_excluding :skip_on_jruby => !defined?(::JRUBY_VERSION).nil?

  # We can't support outerWidth and outerHeight without a visible window.
  # We focus the next window instead of failing when closing windows.
  c.filter_run_excluding :full_description =>
    /Capybara::Session webkit Capybara::Window #(size|resize_to|maximize|close.*no_such_window_error)/

  # Capybara's integration tests expect "capybara/" in the default path
  c.around :requires => :screenshot do |example|
    old_path = Capybara.save_and_open_page_path
    Capybara.save_and_open_page_path = File.join(PROJECT_ROOT, 'tmp', 'capybara')

    begin
      example.run
    ensure
    Capybara.save_and_open_page_path = old_path
    end
  end
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
