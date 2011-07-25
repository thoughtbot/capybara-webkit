require "fileutils"

module CapybaraWebkitBuilder
  extend self

  def make_bin
    make_binaries = ['gmake', 'make']
    make_binaries.detect { |make| system("which #{make}") }
  end

  def makefile
    qmake_binaries = ['qmake', 'qmake-qt4']
    qmake = qmake_binaries.detect { |qmake| system("which #{qmake}") }
    case RUBY_PLATFORM
    when /linux/
      system("#{qmake} -spec linux-g++")
    when /freebsd/
      system("#{qmake} -spec freebsd-g++")
    else
      system("#{qmake} -spec macx-g++")
    end
  end

  def qmake
    system("#{make_bin} qmake")
  end

  def build
    system(make_bin) or return false

    FileUtils.mkdir("bin") unless File.directory?("bin")
    FileUtils.cp("src/webkit_server", "bin", :preserve => true)
  end

  def build_all
    makefile &&
    qmake &&
    build
  end
end
