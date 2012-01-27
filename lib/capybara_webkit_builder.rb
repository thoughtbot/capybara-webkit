require "fileutils"
require "rbconfig"

module CapybaraWebkitBuilder
  extend self

  def make_bin
    ENV['MAKE'] || 'make'
  end

  def qmake_bin
    ENV['QMAKE'] || 'qmake'
  end

  def spec
    ENV['SPEC'] || os_spec
  end

  def os_spec
    case RbConfig::CONFIG['host_os']
    when /linux/
      "linux-g++"
    when /freebsd/
      "freebsd-g++"
    else
      "macx-g++"
    end
  end

  def makefile
    system("#{qmake_bin} -spec #{spec}")
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
