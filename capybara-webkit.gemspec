Gem::Specification.new do |s|
  s.name = "capybara-webkit"
  s.version = "0.1.5"
  s.authors = ["thoughtbot", "Joe Ferris", "Jason Morrison", "Tristan Dunn"]
  s.email = "support@thoughtbot.com"
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {spec,features}/*`.split("\n")
  s.homepage = "http://github.com/thoughtbot/capybara-webkit"
  s.require_path = "lib"
  s.rubygems_version = "1.3.5"
  s.summary = "Headless Webkit driver for Capybara"
  s.add_runtime_dependency "capybara", "~> 0.4.1"
  s.add_runtime_dependency "rake"
  s.extensions = "extconf.rb"
end

