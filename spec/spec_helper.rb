require 'rspec'
require 'rspec/autorun'

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

require File.join(spec_dir,"spec_helper")

require 'capybara/driver/webkit/browser'
$webkit_browser = Capybara::Driver::Webkit::Browser.new(:socket_class => TCPSocket, :stdout => nil)

Capybara.register_driver :reusable_webkit do |app|
  Capybara::Driver::Webkit.new(app, :browser => $webkit_browser)
end
