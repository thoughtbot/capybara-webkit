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
    convert_makefile_from_latin1_to_utf8_if_necessary
  end

  def qmake
    system("#{make_bin} qmake")
    convert_makefile_from_latin1_to_utf8_if_necessary
  end
  
  def makefile_in_latin1?
    `file Makefile`.include?("ISO-8859")
  end
  
  def convert_makefile_from_latin1_to_utf8_if_necessary
    system("iconv -f latin1 -t utf8 Makefile > Makefile.utf8 && mv Makefile.utf8 Makefile") if makefile_in_latin1?
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
