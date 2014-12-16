require 'mkmf'
$CPPFLAGS = ""

dir_config("gl")
dir_config("zlib")

includepath = $CPPFLAGS.gsub("-I", '').strip
libs = $LIBPATH.map {|p| "-L#{p}"}.join(" ").strip

unless includepath.empty?
  ENV["CAPYBARA_WEBKIT_INCLUDEPATH"] = includepath
end
unless libs.empty?
  ENV["CAPYBARA_WEBKIT_LIBS"] = libs
end

require File.join(File.expand_path(File.dirname(__FILE__)), "lib", "capybara_webkit_builder")
CapybaraWebkitBuilder.build_all
