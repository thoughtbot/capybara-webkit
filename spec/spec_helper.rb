require 'rspec'
require 'rspec/autorun'

PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..')).freeze

$LOAD_PATH << File.join(PROJECT_ROOT, 'lib')
ENV["PATH"] = ENV["PATH"] + ":" + File.join(PROJECT_ROOT, "bin")

Dir[File.join(PROJECT_ROOT, 'spec', 'support', '**', '*.rb')].each { |file| require(file) }

