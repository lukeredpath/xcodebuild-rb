require 'spec_helper'

describe XcodeBuild::BuildReporter do
  let(:reporter) { XcodeBuild::BuildReporter.new }
  
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
    
    it "reports that the build was successful" do
      reporter.build_successful?.should be_true
    end
    
    it "reports the total number of completed build actions" do
      reporter.should have(3).build_actions_completed
    end
    
    it "reports the build target" do
      reporter.build_target.should == "ExampleProject"
    end
    
    it "reports the project name" do
      reporter.project_name.should == "ExampleProject"
    end
    
    it "reports the build configuration" do
      reporter.build_configuration.should == "Release"
    end
    
    it "repoerts if the build configuration was the default" do
      reporter.was_default_build_configuration?.should == true
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
