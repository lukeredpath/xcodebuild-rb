# encoding: UTF-8
$:.unshift("lib")

require "bundler/setup"
require 'xcode_build'
require 'xcode_build/output_translator'
require 'xcode_build/tasks/build_task'
require 'pp'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

class InspectReporter
  def build_started(params)
    pp({build_started: params})
  end
  
  def clean_step(params)
    pp({build_step: params})
  end
  
  def build_error_detected(params)
    pp({build_error_detected: params})
  end
  
  def build_succeeded
    pp({build_succeeded: {}})
  end
  
  def build_failed
    pp({build_failed: {}})
  end
  
  def build_step_failed(params)
    pp({build_step_failed: params})
  end
  
  def clean_started(params)
    pp({clean_started: params})
  end
  
  def clean_step(params)
    pp({clean_step: params})
  end
  
  def clean_error_detected(params)
    pp({clean_error_detected: params})
  end
  
  def clean_succeeded
    pp({clean_succeeded: {}})
  end
  
  def clean_failed
    pp({clean_failed: {}})
  end
  
  def clean_step_failed(params)
    pp({clean_step_failed: params})
  end
end

namespace :examples do
  XcodeBuild::Tasks::BuildTask.new do |t|
    t.invoke_from_within = "resources/ExampleProject"
    t.formatter = XcodeBuild::Formatters::ProgressFormatter.new
    #t.reporter = InspectReporter.new
  end
end

task :run_tests => :clean_example do
  Dir.chdir("resources/ExampleProject") do
    reporter = OutputFormatter.new
    XcodeBuild.run("-target ExampleProjectTests -sdk iphonesimulator5.0 TEST_HOST=", XcodeBuild::OutputTranslator.new(reporter))
  end
end

task :simulate_clean_fail do
  Rake::Task["examples:xcode:build"].invoke
  FileUtils.chmod(000, "resources/ExampleProject/build/Release-iphoneos/ExampleProject.app")
  Rake::Task["examples:xcode:clean"].invoke
end

require "rubygems"
require "rubygems/package_task"
require "rdoc/task"

# This builds the actual gem. For details of what all these options
# mean, and other ones you can add, check the documentation here:
#
#   http://rubygems.org/read/chapter/20
#
spec = Gem::Specification.new do |s|

  # Change these as appropriate
  s.name              = "xcodebuild-rb"
  s.version           = "0.1.0"
  s.summary           = "Build Xcode projects using Rake"
  s.author            = "Luke Redpath"
  s.email             = "luke@lukeredpath.co.uk"
  s.homepage          = "http://github.com/lukeredpath/xcodebuild-rb"

  s.has_rdoc          = false
  s.extra_rdoc_files  = %w(README.md)
  s.rdoc_options      = %w(--main README.md)

  # Add any extra files to include in the gem
  s.files             = %w(LICENSE README.md) + Dir.glob("{bin,spec,lib}/**/*")
  s.executables       = FileList["bin/**"].map { |f| File.basename(f) }
  s.require_paths     = ["lib"]

  # If you want to depend on other gems, add them here, along with any
  # relevant versions
  s.add_dependency("state_machine", "~> 1.1.2")

  # If your tests use any gems, include them here
  s.add_development_dependency("rspec")
  s.add_development_dependency("rake", "~> 0.9.2.2")
  s.add_development_dependency("rdoc", "~> 3.12")
  s.add_development_dependency("guard-rspec")
  s.add_development_dependency("growl")
  s.add_development_dependency("timecop")
  s.add_development_dependency("chronic")
end

# This task actually builds the gem. We also regenerate a static
# .gemspec file, which is useful if something (i.e. GitHub) will
# be automatically building a gem for this project. If you're not
# using GitHub, edit as appropriate.
#
# To publish your gem online, install the 'gemcutter' gem; Read more 
# about that here: http://gemcutter.org/pages/gem_docs
Gem::PackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Build the gemspec file #{spec.name}.gemspec"
task :gemspec do
  file = File.dirname(__FILE__) + "/#{spec.name}.gemspec"
  File.open(file, "w") {|f| f << spec.to_ruby }
end

# If you don't want to generate the .gemspec file, just remove this line. Reasons
# why you might want to generate a gemspec:
#  - using bundler with a git source
#  - building the gem without rake (i.e. gem build blah.gemspec)
#  - maybe others?
task :package => :gemspec

# Generate documentation
RDoc::Task.new do |rd|
  rd.main = "README.md"
  rd.rdoc_files.include("README.md", "lib/**/*.rb")
  rd.rdoc_dir = "rdoc"
end

desc 'Clear out RDoc and generated packages'
task :clean => [:clobber_rdoc, :clobber_package] do
  rm "#{spec.name}.gemspec"
end

desc "Bundle the gems from the gemspec"
task :bundle => :gemspec do
  system "bundle install"
end
