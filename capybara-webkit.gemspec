Gem::Specification.new do |s|
  s.name = "capybara-webkit"
  s.version = "0.1.0"
  s.authors = ["thoughtbot", "Joe Ferris", "Jason Morrison", "Tristan Dunn"]
  s.email = "support@thoughtbot.com"
  s.files        = Dir['[A-Z]*', 'lib/**/*.rb', 'spec/**/*.rb', '**/*.pro', 'src/*.cpp', 'src/*.h', 'src/*.qrc', 'src/*.pro', 'src/*.js', "extconf.rb", "bin/*"]
  s.homepage = "http://github.com/thoughtbot/capybara-webkit"
  s.require_path = "lib"
  s.rubygems_version = "1.3.5"
  s.summary = "Headless Webkit driver for Capybara"
  s.add_runtime_dependency "capybara", "~> 0.4.1"
  s.add_runtime_dependency "sinatra", "~> 1.1.2"
  s.extensions = "extconf.rb"
end

