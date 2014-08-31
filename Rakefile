# Bootstrap task
#-----------------------------------------------------------------------------#

desc 'Install dependencies'
task :bootstrap do
  if system('which bundle')
    sh "bundle install"
  else
    $stderr.puts "\033[0;31m" \
      "[!] Please install the bundler gem manually:\n" \
      '    $ [sudo] gem install bundler' \
      "\e[0m"
    exit 1
  end
end

begin

  task :build do
    title "Building the gem"
  end

  require "bundler/gem_tasks"

  # Release tasks
  #-----------------------------------------------------------------------------#

  desc "Build the gem for distribution"
  task :release_build => ['ext:clean', 'ext:precompile', :build]

  desc "Runs the tasks necessary for the release of the gem"
  task :pre_release do
    title "Running pre-release tasks"
    tmp = File.expand_path('../tmp', __FILE__)
    sh "rm -rf '#{tmp}'"
    Rake::Task[:release_build].invoke
  end

  # Always prebuilt for gems!
  Rake::Task[:build].enhance [:pre_release]

  # Ext Namespace
  #-----------------------------------------------------------------------------#

  namespace :ext do
    desc "Clean the ext files"
    task :clean do
      title "Cleaning extension"
      sh "cd ext/xcodeproj && rm -f Makefile *.o *.bundle prebuilt/**/*.o prebuilt/**/*.bundle"
    end

    desc "Build the ext"
    task :build do
      title "Building the extension"
      Dir.chdir 'ext/xcodeproj' do
        if on_rvm?
          sh "CFLAGS='-I#{rvm_ruby_dir}/include' ruby extconf.rb"
        else
          sh "ruby extconf.rb"
        end
        sh "make"
      end
    end

    desc "Pre-compile the ext for default Ruby on 10.8 and 10.9"
    task :precompile do
      title "Pre-compiling the extension"
      versions = Dir.glob(File.expand_path('../ext/xcodeproj/prebuilt/*darwin*', __FILE__)).sort
      versions.each do |version|
        Dir.chdir version do
          subtitle "#{File.basename(version)}"
          sh "make"
        end
      end
    end

    desc "Clean and build the ext"
    task :cleanbuild => [:clean, :build]
  end

  # Travis support
  def on_rvm?
    `which ruby`.strip.include?('.rvm')
  end

  def rvm_ruby_dir
    @rvm_ruby_dir ||= File.expand_path('../..', `which ruby`.strip)
  end

  # Common Build settings
  #-----------------------------------------------------------------------------#

  namespace :common_build_settings do
    PROJECT_DIR = 'project'
    PROJECT_PATH = "#{PROJECT_DIR}/Project.xcodeproj"

    task :prepare, [:dir_name] do |_, args|
      verbose false
      require 'xcodeproj'
      dir_name = args[:dir_name] || Xcodeproj::Application.current.config_identifier
      cd "data/#{dir_name}"
    end

    desc "Create a new empty project"
    task :new_project => [:prepare] do
      verbose false
      require 'xcodeproj'
      title "Setup Boilerplate"

      if Dir.exist?(PROJECT_PATH)
        confirm "Delete existing fixture project and all data"
        rm_rf PROJECT_DIR
      end
      mkdir_p PROJECT_DIR

      subtitle "Create a new fixture project"
      Xcodeproj::Project.new(PROJECT_PATH).save

      subtitle "Open the project …"
      sh "open '#{PROJECT_PATH}'"
    end

    desc "Interactive walkthrough for creating fixture targets"
    task :targets, [:pre6] => [:prepare] do |t, args|
      verbose false
      require 'xcodeproj'

      title "Create Targets"
      subtitle "You will be guided how to *manually* create the needed targets."
      subtitle "Each target name will been copied to your clipboard."
      confirm "Make sure you have nothing unsaved there"

      targets = {
        "Objc_iOS_Native"         => "iOS > Master-Detail Application > Language: Objective-C",
        "Swift_iOS_Native"        => "iOS > Master-Detail Application > Language: Swift",
        "Objc_iOS_Framework"      => "iOS > Cocoa Touch Framework > Language: Objective-C",
        "Swift_iOS_Framework"     => "iOS > Cocoa Touch Framework > Language: Swift",
        "Objc_iOS_StaticLibrary"  => "iOS > Cocoa Touch Static Library",
        "Objc_OSX_Native"         => "OSX > Cocoa Application > Language: Objective-C",
        "Swift_OSX_Native"        => "OSX > Cocoa Application > Language: Swift",
        "Objc_OSX_Framework"      => "OSX > Cocoa Framework > Language: Objective-C",
        "Swift_OSX_Framework"     => "OSX > Cocoa Framework > Language: Swift",
        "Objc_OSX_StaticLibrary"  => "OSX > Library > Type: Static",
        "Objc_OSX_DynamicLibrary" => "OSX > Library > Type: Dynamic",
        "OSX_Bundle"              => "OSX > Bundle",
      }

      targets.each do |name, explanation|
        target_config = Xcodeproj::Constants::TARGET_CONFIGURATIONS[name]
        if args[:pre6]
          next if target_config.language == :swift
          next if target_config.platform == :ios && target_config.product_type == :framework
        end
        begin
          sh "printf '#{name}' | pbcopy"
          confirm "Create a target named '#{name}' by: #{explanation}", false

          project = Xcodeproj::Project.open(PROJECT_PATH)
          raise "Project couldn't be opened." if project.nil?

          target = project.targets.find { |t| t.name == name }
          raise "Target wasn't found." if target.nil?

          raise "Platform doesn't match." unless target.platform_name == target_config.platform
          raise "Type doesn't match."     unless target.symbol_type   == target_config.product_type

          debug_config= target.build_configurations.find { |c| c.name = 'Debug' }
          raise "Debug configuration is missing" if debug_config.nil?

          release_config = target.build_configurations.find { |c| c.name = 'Release' }
          raise "Release configuration is missing" if release_config.nil?

          is_swift_present  = debug_config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] != nil
          is_swift_expected = target_config.language == :swift
          raise "Language doesn't match." unless is_swift_present == is_swift_expected

          puts green("Target matches.")
          puts
        rescue StandardError => e
          raise e if e.message == "Aborted by user."
          puts "#{red(e.message)} Try again."
          retry
        end
      end

      puts green("All targets were been successfully created.")
    end

    desc "Dump the build settings of the fixture project to xcconfig files"
    task :dump, [:dir_name] => [:prepare] do
      verbose false
      mkdir_p 'configs'
      sh '../../bin/xcodeproj config-dump project/Project.xcodeproj configs'
    end

    desc "(Re-)Dump all fixture projects to xcconfig files"
    task :dump_all do
      Dir['data/*'].each do |dir|
        dir_name = File.basename(dir)
        # Rake::Task[].invoke won't work here, because the chdir side-effect
        sh "rake common_build_settings:dump[#{dir_name}]"
      end
    end

    desc "Recreate the xcconfig files for the fixture project targets from scratch"
    task :rebuild => [
      :new_project,
      :targets,
      :dump,
    ]
  end

  #-----------------------------------------------------------------------------#

  namespace :spec do
    desc "Run all specs"
    task :all do
      puts "\n\033[0;32mUsing #{`ruby --version`.chomp}\033[0m"
      Rake::Task["ext:cleanbuild"].invoke

      title "Running the specs"
      ENV['GENERATE_COVERAGE'] = 'true'
      sh "bundle exec bacon #{FileList['spec/**/*_spec.rb'].join(' ')}"
    end

    desc "Automatically run specs"
    task :kick do
      exec "bundle exec kicker -c"
    end

    desc "Run single spec"
    task :single, :spec_file do |t, args|
      sh "bundle exec bacon #{args.spec_file}"
    end
  end

  desc "Run all specs"
  task :spec => 'spec:all'

  task :default => :spec

rescue LoadError
  $stderr.puts "\033[0;31m" \
    '[!] Some Rake tasks haven been disabled because the environment' \
    ' couldn’t be loaded. Be sure to run `rake bootstrap` first.' \
    "\e[0m"
end

# UI Helpers
#-----------------------------------------------------------------------------#

# Prints a title.
#
def title(string)
  puts
  puts yellow(string)
  puts "-" * 80
end

# Prints a subtitle
#
def subtitle(string)
  puts cyan(string)
end

# Colorizes a string to yellow.
#
def yellow(string)
  "\033[0;33m#{string}\e[0m"
end

# Colorizes a string to red.
#
def red(string)
  "\033[0;31m#{string}\e[0m"
end

# Colorizes a string to green.
#
def green(string)
  "\033[0;32m#{string}\e[0m"
end

# Colorizes a string to cyan.
#
def cyan(string)
  "\n\033[0;36m#{string}\033[0m"
end

def confirm(message, decline_by_default=true)
  options = ['y', 'n']
  options[decline_by_default ? 1 : 0].upcase!
  print yellow("#{message}: [#{options.join('/')}] ")
  input = STDIN.gets.chomp
  if input == options[1].downcase || (input == '' && decline_by_default)
    puts red("Aborted by user.")
    exit 1
  end
end
