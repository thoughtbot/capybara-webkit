require "fileutils"
require "rbconfig"
require "shellwords"

module CapybaraWebkitBuilder
  extend self

  SUCCESS_STATUS = 0
  COMMAND_NOT_FOUND_STATUS = 127

  def make_bin
    ENV['MAKE'] || 'make'
  end

  def qmake_bin
    ENV['QMAKE'] || default_qmake_binary
  end

  def default_qmake_binary
    case RbConfig::CONFIG['host_os']
    when /freebsd/
      "qmake-qt4"
    when /openbsd/
      "qmake-qt5"
    else
      "qmake"
    end
  end

  def sh(command)
    system(command)
    success = $?.exitstatus == SUCCESS_STATUS
    if $?.exitstatus == COMMAND_NOT_FOUND_STATUS
      puts "Command '#{command}' not available"
    elsif !success
      puts "Command '#{command}' failed"
    end
    success
  end

  def makefile(*configs)
    configs += default_configs
    configs = configs.map { |config| config.shellescape}.join(" ")
    sh("#{qmake_bin} #{configs}")
  end

  def qmake
    make "qmake"
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
    make or return false

    FileUtils.mkdir("bin") unless File.directory?("bin")
    FileUtils.cp(path_to_binary, "bin", :preserve => true)
  end

  def clean
    File.open("Makefile", "w") do |file|
      file.print "all:\n\t@echo ok\ninstall:\n\t@echo ok"
    end
  end

  def default_configs
    configs = []
    libpath = ENV["CAPYBARA_WEBKIT_LIBS"]
    cppflags = ENV["CAPYBARA_WEBKIT_INCLUDE_PATH"]
    if libpath
      configs << "LIBS += #{libpath}"
    end
    if cppflags
      configs << "INCLUDEPATH += #{cppflags}"
    end
    configs
  end

  def build_all
    makefile &&
    qmake &&
    build &&
    clean
  end

  def make(target = "")
    env_hide("CDPATH") { sh("#{make_bin} #{target}") }
  end

  def env_hide(name)
    @stored_env ||= {}
    @stored_env[name] = ENV.delete(name)

    yield
  ensure
    ENV[name] = @stored_env[name]
  end
end
