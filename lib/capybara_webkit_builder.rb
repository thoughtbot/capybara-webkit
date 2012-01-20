require "fileutils"
require "rbconfig"

module CapybaraWebkitBuilder
  extend self

  def has_binary?(binary)
    case RbConfig::CONFIG['host_os']
    when /mingw32/
      system("#{binary} --version")
    else
      system("which #{make}")
    end
  end
  
  def make_bin
    make_binaries = ['gmake', 'make']
    make_binaries.detect { |make| has_binary?(make) }
  end

  def qmake_bin
    qmake_binaries = ['qmake', 'qmake-qt4']
    qmake_binaries.detect { |qmake| has_binary?(qmake) }
  end
  
  def makefile
    case RbConfig::CONFIG['host_os']
    when /linux/
      system("#{qmake_bin} -spec linux-g++")
    when /freebsd/
      system("#{qmake_bin} -spec freebsd-g++")
    when /mingw32/
      system("#{qmake_bin} -spec win32-g++")
    else
      system("#{qmake_bin} -spec macx-g++")
    end
  end

  def qmake
    system("#{make_bin} qmake")
  end

  def path_to_binary
    case RbConfig::CONFIG['host_os']
    when /mingw32/
      'src/debug/webkit_server.exe'
    else
      'src/webkit_server'
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
