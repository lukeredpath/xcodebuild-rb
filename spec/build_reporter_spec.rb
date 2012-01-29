require 'spec_helper'

describe XcodeBuild::BuildReporter do
  let(:reporter) { XcodeBuild::BuildReporter.new }
  
  shared_examples_for "any build" do
    it "reports the build target" do
      reporter.build.target.should == "ExampleProject"
    end
    
    it "reports the project name" do
      reporter.build.project_name.should == "ExampleProject"
    end
    
    it "reports the build configuration" do
      reporter.build.configuration.should == "Release"
    end
    
    it "reports if the build configuration was the default" do
      reporter.build.should be_default_configuration
    end
  end
  
  context "for a started build" do
    before do
      event({:build_started=>
        {:target=>"ExampleProject",
         :project=>"ExampleProject",
         :configuration=>"Release",
         :default=>true}})
    end
    
    it "reports that the build is running" do
      reporter.build.should be_running
    end
    
    it "reports that the build is not finished" do
      reporter.build.should_not be_finished
    end
  end
  
  context "for a simple, successful build" do
    before do
      event({:build_started=>
        {:target=>"ExampleProject",
         :project=>"ExampleProject",
         :configuration=>"Release",
         :default=>true}})
         
      event({:build_action=>
        {:type=>"CpResource",
         :arguments=>
          ["/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS5.0.sdk/ResourceRules.plist",
           "build/Release-iphoneos/ExampleProject.app/ResourceRules.plist"]}})
           
      event({:build_action=>
        {:type=>"ProcessInfoPlistFile",
         :arguments=>
          ["build/Release-iphoneos/ExampleProject.app/Info.plist",
           "ExampleProject/ExampleProject-Info.plist"]}})
           
      event({:build_action=>
        {:type=>"CompileC",
         :arguments=>
          ["build/ExampleProject.build/Release-iphoneos/ExampleProject.build/Objects-normal/armv7/AppDelegate.o",
           "ExampleProject/AppDelegate.m",
           "normal",
           "armv7",
           "objective-c",
           "com.apple.compilers.llvm.clang.1_0.compiler"]}})
           
      event({:build_succeeded=>{}})
    end
    
    it_behaves_like "any build"
    
    it "reports that the build was successful" do
      reporter.build.should be_successful
    end
    
    it "reports the total number of completed build actions" do
      reporter.build.should have(3).actions_completed
    end
    
    it "reports that the build is not running" do
      reporter.build.should_not be_running
    end
    
    it "reports that the build is finished" do
      reporter.build.should be_finished
    end
  end
  
  private
  
  def event(event_data)
    message = event_data.keys.first
    params = event_data.values.first
    
    if params.any?
      reporter.send(message, params)
    else
      reporter.send(message)
    end
  end
end
