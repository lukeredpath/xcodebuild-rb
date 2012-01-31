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

  context "build task" do
    it "runs xcodebuild with the configured build_opts" do
      task = XcodeBuild::Tasks::BuildTask.new do |task|
        task.project_name = "TestProject.xcproject"
        task.configuration = "Debug"
      end
      
      XcodeBuild.should_receive(:run).with(task.build_opts.join(" "), anything()).and_return(0)
      task.run(:build)
    end
    
    it "defaults to outputting the raw output to STDOUT" do
      task = XcodeBuild::Tasks::BuildTask.new
      
      XcodeBuild.should_receive(:run).with(anything(), STDOUT).and_return(0)
      task.run(:build)
    end
    
    it "uses a custom output buffer if specified" do
      buffer = stub('output buffer')
      task = XcodeBuild::Tasks::BuildTask.new do |t|
        t.output_to = buffer
      end
      
      XcodeBuild.should_receive(:run).with(anything(), buffer).and_return(0)
      task.run(:build)
    end
    
    it "outputs the translator delegating to the reporter if formatter is set" do
      formatter = stub('formatter')
      task = XcodeBuild::Tasks::BuildTask.new do |t|
        t.formatter = formatter
      end
      
      XcodeBuild.should_receive(:run).with(anything(),
        output_translator_delegating_to(instance_of(XcodeBuild::Reporter))).and_return(0)
      task.run(:build)
    end
    
    it "changes directory if invoke_from_within is set" do
      task = XcodeBuild::Tasks::BuildTask.new do |task|
        task.invoke_from_within = "foo/bar"
      end
      
      Dir.should_receive(:chdir).with("foo/bar").and_yield
      XcodeBuild.should_receive(:run).and_return(0)
      task.run(:build)
    end
    
    it "raises if xcodebuild returns a non-zero exit code" do
      task = XcodeBuild::Tasks::BuildTask.new
      XcodeBuild.stub(:run).with(anything(), anything()).and_return(99)
      -> { task.run(:build) }.should raise_error
    end
  end
  
  context "clean task" do
    it "runs xcodebuild with the 'clean' action" do
      task = XcodeBuild::Tasks::BuildTask.new
      XcodeBuild.should_receive(:run).with("clean", anything()).and_return(0)
      task.run(:clean)
    end
    
    it "raises if xcodebuild returns a non-zero exit code" do
      task = XcodeBuild::Tasks::BuildTask.new
      XcodeBuild.stub(:run).with(anything(), anything()).and_return(99)
      -> { task.run(:build) }.should raise_error
    end
  end
  
  context "cleanbuild task" do
    it "runs the clean task and then the build task" do
      task = XcodeBuild::Tasks::BuildTask.new
      
      XcodeBuild.should_receive(:run).with("clean", anything()).ordered.and_return(0)
      XcodeBuild.should_receive(:run).with("", anything()).ordered.and_return(0)

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
