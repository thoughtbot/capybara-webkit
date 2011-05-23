require "fileutils"

module CapybaraWebkitBuilder
  extend self

  def makefile
    case RUBY_PLATFORM
    when /linux/
      system("qmake -spec linux-g++")
    else
      system("qmake -spec macx-g++")
    end
  end

  def qmake
    system("make qmake")
  end

  def build
    system("make") or return false

    FileUtils.mkdir("bin") unless File.directory?("bin")
    if !(RUBY_PLATFORM =~ /linux/) && File.exist?("src/webkit_server.app")
      FileUtils.cp("src/webkit_server.app/Contents/MacOS/webkit_server", "bin", :preserve => true)
    else
      FileUtils.cp("src/webkit_server", "bin", :preserve => true)
    end
  end

  def build_all
    makefile &&
    qmake &&
    build
  end
end
