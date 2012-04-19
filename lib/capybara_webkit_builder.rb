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
    when /mingw32/
      "win32-g++"
    else
      "macx-g++"
    end
  end

  def makefile
    system("#{make_env_variables} #{qmake_bin} -spec #{spec}")
  end

  def qmake
    system("#{make_env_variables} #{make_bin} qmake")
  end

  def make_env_variables
    case RbConfig::CONFIG['host_os']
    when /mingw32/
      ''
    else
      "LANG='en_US.UTF-8'"
    end
  end

  def path_to_binary
    case RUBY_PLATFORM
    when /mingw32/
      "src/debug/webkit_server.exe"
    else
      "src/webkit_server"
    end
  end

  def build
    system(make_bin) or return false

    FileUtils.mkdir("bin") unless File.directory?("bin")
    FileUtils.cp(path_to_binary, "bin", :preserve => true)
  end

  def build_all
    makefile &&
    qmake &&
    build
  end
end
