$:.push File.expand_path("../lib", __FILE__)
require "capybara/driver/webkit/version"

Gem::Specification.new do |s|
  s.name     = "capybara-webkit"
  s.version  = Capybara::Driver::Webkit::VERSION.dup
  s.authors  = ["thoughtbot", "Joe Ferris", "Matt Mongeau", "Mike Burns", "Jason Morrison"]
  s.email    = "support@thoughtbot.com"
  s.homepage = "http://github.com/thoughtbot/capybara-webkit"
  s.summary  = "Headless Webkit driver for Capybara"

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- {spec,features}/*`.split("\n")
  s.require_path = "lib"

  s.extensions = "extconf.rb"

  s.add_runtime_dependency("capybara", [">= 1.0.0", "< 1.2"])
  s.add_runtime_dependency("json")

  s.add_development_dependency("rspec", "~> 2.6.0")
  # Sinatra is used by Capybara's TestApp
  s.add_development_dependency("sinatra")
  s.add_development_dependency("mini_magick")
  s.add_development_dependency("rake")
  s.add_development_dependency("appraisal", "~> 0.4.0")
end

