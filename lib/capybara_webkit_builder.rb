require "fileutils"

module CapybaraWebkitBuilder
  extend self

  def makefile
    system("qmake -spec macx-g++")
  end

  def qmake
    system("make qmake")
  end

  def build
    system("make") or return false

    FileUtils.mkdir("bin") unless File.directory?("bin")
    FileUtils.cp("src/webkit_server", "bin", :preserve => true)
  end

  def build_all
    makefile &&
    qmake &&
    build
  end
end
