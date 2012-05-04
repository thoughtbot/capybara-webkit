require 'rspec'
require 'rspec/autorun'
require 'rbconfig'

PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..')).freeze

$LOAD_PATH << File.join(PROJECT_ROOT, 'lib')

Dir[File.join(PROJECT_ROOT, 'spec', 'support', '**', '*.rb')].each { |file| require(file) }

spec_dir = nil
$:.detect do |dir|
  if File.exists? File.join(dir, "capybara.rb")
    spec_dir = File.expand_path(File.join(dir,"..","spec"))
    $:.unshift( spec_dir )
  end
end

RSpec.configure do |c|
  c.filter_run_excluding :skip_on_windows => !(RbConfig::CONFIG['host_os'] =~ /mingw32/).nil?
end

require File.join(spec_dir, "spec_helper")

require 'capybara/driver/webkit/connection'
require 'capybara/driver/webkit/browser'
connection = Capybara::Driver::Webkit::Connection.new(:socket_class => TCPSocket, :stdout => nil)
$webkit_browser = Capybara::Driver::Webkit::Browser.new(connection)

Capybara.register_driver :reusable_webkit do |app|
  Capybara::Driver::Webkit.new(app, :browser => $webkit_browser)
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
