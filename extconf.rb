require File.join(File.expand_path(File.dirname(__FILE__)), "lib", "capybara_webkit_builder")

if system("qmake").nil?
  error = "Couldn't find the 'qmake' executable. Please install Qt and then proceed."

  raise(error)
else
  CapybaraWebkitBuilder.build_all
end
