require "fileutils"

module CapybaraWebkitBuilder
  extend self

  def make_bin
    make_binaries = ['gmake', 'make']
	case RUBY_PLATFORM
	when /mingw32/
	  make_binaries.last
	else	  
      make_binaries.detect { |make| system("which #{make}") }
	end    
  end

  def qmake_bin
    qmake_binaries = ['qmake', 'qmake-qt4']
    case RUBY_PLATFORM
	when /mingw32/
	  qmake_binaries.first
	else
	  qmake_binaries.detect { |qmake| system("which #{qmake}") }
	end
  end
  
  def makefile
    case RUBY_PLATFORM
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
	case RUBY_PLATFORM
	when /mingw32/
	  'src/debug/webkit_server.exe'
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
