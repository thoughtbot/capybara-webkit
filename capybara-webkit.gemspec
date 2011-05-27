Gem::Specification.new do |s|
  s.name = "capybara-webkit"
  s.version = "0.4.0"
  s.authors = ["thoughtbot", "Joe Ferris", "Jason Morrison", "Tristan Dunn",
               "Joshua Clayton", "Yuichi Tateno", "Aaron Gibralter",
               "Vasily Reys", "petrushka", "John Bintz",
               "Christopher Meiklejohn", "John Barker", "Jeremy Wells"]
  s.email = "support@thoughtbot.com"
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {spec,features}/*`.split("\n")
  s.homepage = "http://github.com/thoughtbot/capybara-webkit"
  s.require_path = "lib"
  s.rubygems_version = "1.3.5"
  s.summary = "Headless Webkit driver for Capybara"
  s.add_runtime_dependency "capybara", "~> 0.4.1"
  s.extensions = "extconf.rb"
end

