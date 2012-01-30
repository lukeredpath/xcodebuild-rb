# encoding: UTF-8
$:.unshift("lib")

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
