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
  
  context "for a simple, failed build" do
    before do
      event({:build_started=>
        {:target=>"ExampleProject",
         :project=>"ExampleProject",
         :configuration=>"Release",
         :default=>true}})

      event({:build_action=>
        {:type=>"CompileC",
         :arguments=>
          ["build/ExampleProject.build/Release-iphoneos/ExampleProject.build/Objects-normal/armv7/AppDelegate.o",
           "ExampleProject/AppDelegate.m",
           "normal",
           "armv7",
           "objective-c",
           "com.apple.compilers.llvm.clang.1_0.compiler"]}})
           
      event({:build_error_detected=>
         {:file=>
           "/Users/luke/Code/mine/xcodebuild/resources/ExampleProject/ExampleProject/main.m",
          :line=>16,
          :char=>42,
          :message=>"expected ';' after expression [1]"}})
      
      event({:build_action=>
        {:type=>"CompileC",
         :arguments=>
          ["build/ExampleProject.build/Release-iphoneos/ExampleProject.build/Objects-normal/armv7/AppDelegate.o",
           "ExampleProject/AppDelegate.m",
           "normal",
           "armv7",
           "objective-c",
           "com.apple.compilers.llvm.clang.1_0.compiler"]}})
           
      event({:build_failed=>{}})
      
      event({:build_action_failed=>
        {:type=>"CompileC",
         :arguments=>
          ["build/ExampleProject.build/AlwaysFails-iphoneos/ExampleProject.build/Objects-normal/armv7/AppDelegate.o",
           "ExampleProject/AppDelegate.m",
           "normal",
           "armv7",
           "objective-c",
           "com.apple.compilers.llvm.clang.1_0.compiler"]}})
    end
    
    it "reports that the build was a failure" do
      reporter.build.should be_failed
    end
    
    it "reports the total number of completed build actions" do
      reporter.build.should have(2).actions_completed
    end
    
    it "reports the total number of failed build actions" do
      reporter.build.should have(1).failed_actions
      reporter.build.failed_actions.first.tap do |action|
        action.type.should == "CompileC"
      end
    end
    
    it "reports the errors for each failed build action" do
      reporter.build.failed_actions.first.should have(1).errors
      reporter.build.failed_actions.first.errors.first.tap do |error|
        error.file.should == "/Users/luke/Code/mine/xcodebuild/resources/ExampleProject/ExampleProject/main.m"
        error.line.should == 16
        error.char.should == 42
        error.message.should == "expected ';' after expression [1]"
      end
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
