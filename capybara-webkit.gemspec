Gem::Specification.new do |s|
  s.name = "capybara-webkit"
  s.version = "0.7.2"
  s.authors = ["thoughtbot", "Joe Ferris", "Matt Mongeau", "Mike Burns", "Jason Morrison"]
  s.email = "support@thoughtbot.com"
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {spec,features}/*`.split("\n")
  s.homepage = "http://github.com/thoughtbot/capybara-webkit"
  s.require_path = "lib"
  s.rubygems_version = "1.3.5"
  s.summary = "Headless Webkit driver for Capybara"
  s.add_runtime_dependency "capybara", [">= 1.0.0", "< 1.2"]
  s.add_development_dependency "rspec", "~> 2.6.0"
  s.add_development_dependency "sinatra"
  s.add_development_dependency "mini_magick"
  s.add_development_dependency "rake"
  s.add_development_dependency "appraisal"
  s.extensions = "extconf.rb"
end

