require 'spec_helper'
require 'xcode_build/tasks/build_task'

describe XcodeBuild::Tasks::BuildTask do
  before { Rake::Task.clear }

  it "defines an build task in the default namespace (xcode)" do
    XcodeBuild::Tasks::BuildTask.new
    Rake::Task["xcode:build"].should be_instance_of(Rake::Task)
  end

  it "defines an build task in a custom namespace" do
    XcodeBuild::Tasks::BuildTask.new(:test)
    Rake::Task["test:build"].should be_instance_of(Rake::Task)
  end
  
  it "defines a clean task" do
    XcodeBuild::Tasks::BuildTask.new
    Rake::Task["xcode:clean"].should be_instance_of(Rake::Task)
  end
  
  it "defines a cleanbuild" do
    XcodeBuild::Tasks::BuildTask.new
    Rake::Task["xcode:cleanbuild"].should be_instance_of(Rake::Task)
  end

  context "#build_opts" do
    let(:task) { XcodeBuild::Tasks::BuildTask.new }

    it "includes the project" do
      task.project_name = "TestProject.xcproject"
      task.build_opts.should include("-project TestProject.xcproject")
    end

    it "includes the target" do
      task.target = "TestTarget"
      task.build_opts.should include("-target TestTarget")
    end

    it "includes the workspace" do
      task.workspace = "SomeWorkspace.xcworkspace"
      task.build_opts.should include("-workspace SomeWorkspace.xcworkspace")
    end

    it "includes the scheme" do
      task.scheme = "TestScheme"
      task.build_opts.should include("-scheme TestScheme")
    end

    it "includes the configuration" do
      task.configuration = "TestConfiguration"
      task.build_opts.should include("-configuration TestConfiguration")
    end

    it "includes the arch" do
      task.arch = "i386"
      task.build_opts.should include("-arch i386")
    end

    it "includes the sdk" do
      task.sdk = "iphonesimulator5.0"
      task.build_opts.should include("-sdk iphonesimulator5.0")
    end

    it "includes the xcconfig path" do
      task.xcconfig = "path/to/config.xcconfig"
      task.build_opts.should include("-xcconfig path/to/config.xcconfig")
    end
  end
  
  shared_examples_for "any task" do
    it "directs xcodebuild output into the translator" do
      task = XcodeBuild::Tasks::BuildTask.new
      XcodeBuild.should_receive(:run).with(anything, instance_of(XcodeBuild::OutputTranslator)).and_return(0)
      task.run(task_name)
    end
    
    it "uses a custom output buffer if specified and a formatter has not been set" do
      buffer = stub('output buffer')
      task = XcodeBuild::Tasks::BuildTask.new do |t|
        t.formatter = nil
        t.output_to = buffer
      end
      task.reporter.should_receive(:direct_raw_output_to=).with(buffer)
      XcodeBuild.stub(:run).with(anything, anything).and_return(0)
      task.run(task_name)
    end
    
    it "ignores the value of output_to if a formatter has been set" do
      task = XcodeBuild::Tasks::BuildTask.new do |t|
        t.formatter = stub('formatter')
        t.output_to = stub('output buffer')
      end
      task.reporter.should_not_receive(:direct_raw_output_to=).with(anything)
      XcodeBuild.stub(:run).with(anything, anything).and_return(0)
      task.run(task_name)
    end
    
    it "raises if xcodebuild returns a non-zero exit code" do
      task = XcodeBuild::Tasks::BuildTask.new
      XcodeBuild.stub(:run).with(anything, anything).and_return(99)
      -> { task.run(task_name) }.should raise_error
    end
    
    it "changes directory if invoke_from_within is set" do
      task = XcodeBuild::Tasks::BuildTask.new do |task|
        task.invoke_from_within = "foo/bar"
      end
      
      Dir.should_receive(:chdir).with("foo/bar").and_yield
      XcodeBuild.should_receive(:run).and_return(0)
      task.run(task_name)
    end
  end

  context "build task" do
    let(:task_name) { :build }
    
    it_behaves_like "any task"
    
    it "runs xcodebuild with the configured build_opts" do
      task = XcodeBuild::Tasks::BuildTask.new do |task|
        task.project_name = "TestProject.xcproject"
        task.configuration = "Debug"
      end
      
      XcodeBuild.should_receive(:run).with(task.build_opts.join(" "), anything).and_return(0)
      task.run(:build)
    end
    
    it "calls the after_build block after running successfully, passing in the build object from the report" do
      received_build = nil
      
      task = XcodeBuild::Tasks::BuildTask.new do |task|
        task.after_build do |build|
          expected_build = build
        end
      end
      
      task.stub(:build).and_return(expected_build = stub('build'))
      XcodeBuild.stub(:run).with(anything, anything).and_return(0)

      task.run(:build)

      expected_build.should == expected_build
    end
  end
  
  context "clean task" do
    let(:task_name) { :clean }
    
    it_behaves_like "any task"
    
    it "runs xcodebuild with the 'clean' action" do
      task = XcodeBuild::Tasks::BuildTask.new
      XcodeBuild.should_receive(:run).with("clean", anything).and_return(0)
      task.run(:clean)
    end
  end
  
  context "cleanbuild task" do
    it "runs the clean task and then the build task" do
      task = XcodeBuild::Tasks::BuildTask.new
      
      XcodeBuild.should_receive(:run).with("clean", anything).ordered.and_return(0)
      XcodeBuild.should_receive(:run).with("", anything).ordered.and_return(0)

      task.run(:cleanbuild)
    end
  end
  
  RSpec::Matchers.define :output_translator_delegating_to do |expected|
    match do |actual|
      actual.should be_instance_of(XcodeBuild::OutputTranslator)
      expected.should == actual.delegate
    end
  end
end
