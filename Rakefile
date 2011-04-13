require 'fileutils'

unless ENV["BUILD"]
  require 'rubygems'
  require 'bundler/setup'
  require 'rspec/core/rake_task'
  require 'rake/gempackagetask'
end

desc "Generate a Makefile using qmake"
file 'Makefile' do
  sh("qmake -spec macx-g++")
end

desc "Regenerate dependencies using qmake"
task :qmake => 'Makefile' do
  sh("make qmake")
end

desc "Build the webkit server"
task :build => :qmake do
  sh("make")

  FileUtils.mkdir("bin") unless File.directory?("bin")

  if File.exist?("src/webkit_server.app")
    FileUtils.cp("src/webkit_server.app/Contents/MacOS/webkit_server", "bin", :preserve => true)
  else
    FileUtils.cp("src/webkit_server", "bin", :preserve => true)
  end
end

file 'bin/webkit_server' => :build

unless ENV["BUILD"]
  RSpec::Core::RakeTask.new do |t|
    t.pattern = "spec/**/*_spec.rb"
    t.rspec_opts = "--format progress"
  end

  desc "Default: build and run all specs"
  task :default => [:build, :spec]

  eval("$specification = begin; #{IO.read('capybara-webkit.gemspec')}; end")
  Rake::GemPackageTask.new($specification) do |package|
    package.need_zip = true
    package.need_tar = true
  end

  desc "Generate a new command called NAME"
  task :generate_command do
    name = ENV['NAME'] or raise "Provide a name with NAME="

    header = "src/#{name}.h"
    source = "src/#{name}.cpp"

    %w(h cpp).each do |extension|
      File.open("templates/Command.#{extension}", "r") do |source_file|
        contents = source_file.read
        contents.gsub!("NAME", name)
        File.open("src/#{name}.#{extension}", "w") do |target_file|
          target_file.write(contents)
        end
      end
    end

    Dir.glob("src/*.pro").each do |project_file_name|
      project = IO.read(project_file_name)
      project.gsub!(/^(HEADERS = .*)/, "\\1 #{name}.h")
      project.gsub!(/^(SOURCES = .*)/, "\\1 #{name}.cpp")
      File.open(project_file_name, "w") { |file| file.write(project) }
    end

    File.open("src/find_command.h", "a") do |file|
      file.write("CHECK_COMMAND(#{name})")
    end
  end
end

