require 'spec_helper'

describe XcodeBuild::Reporting::BuildReporting do
  let(:reporter) { XcodeBuild::Reporter.new }
  
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
  
  context "when receiving events" do
    let(:delegate) { mock('reporter delegate').as_null_object }
    
    before do
      reporter.delegate = delegate
      
      # let's assume it responds to all delegate methods
      delegate.stub(:respond_to?).with(anything).and_return(true)
    end
    
    it "notifies it's delegate that a build has started" do
      delegate.should_receive(:build_started).with instance_of(XcodeBuild::Reporting::BuildReporting::Build)
      
      event({:build_started=>
        {:target=>"ExampleProject",
         :project=>"ExampleProject",
         :configuration=>"Release",
         :default=>true}})
    end
    
    it "notifies it's delegate when a build step begins" do
      assume_build_started
      
      delegate.should_receive(:build_step_started).with instance_of(XcodeBuild::BuildStep)
      
      event({:build_step=>
        {:type=>"CpResource",
         :arguments=>
          ["/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS5.0.sdk/ResourceRules.plist",
           "build/Release-iphoneos/ExampleProject.app/ResourceRules.plist"]}})
    end
    
    it "notifies it's delegate when a previous build step finishes" do
      assume_build_started

      event({:build_step=>
        {:type=>"CpResource",
         :arguments=>
          ["/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS5.0.sdk/ResourceRules.plist",
           "build/Release-iphoneos/ExampleProject.app/ResourceRules.plist"]}})
           
      delegate.should_receive(:build_step_finished).with reporter.build.last_step
           
      event({:build_step=>
        {:type=>"CpResource",
         :arguments=>
          ["/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS5.0.sdk/ResourceRules.plist",
           "build/Release-iphoneos/ExampleProject.app/ResourceRules.plist"]}})
    end
    
    it "notifies it's delegate when the last build step finishes and the build is successful" do
      assume_build_started

      event({:build_step=>
        {:type=>"CpResource",
         :arguments=>
          ["/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS5.0.sdk/ResourceRules.plist",
           "build/Release-iphoneos/ExampleProject.app/ResourceRules.plist"]}})
           
      delegate.should_receive(:build_step_finished).with reporter.build.last_step
           
      event({:build_succeeded=>{}})
    end
    
    it "notifies it's delegate when the last build step finishes and the build fails" do
      assume_build_started

      event({:build_step=>
        {:type=>"CpResource",
         :arguments=>
          ["/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS5.0.sdk/ResourceRules.plist",
           "build/Release-iphoneos/ExampleProject.app/ResourceRules.plist"]}})
           
      delegate.should_receive(:build_step_finished).with reporter.build.last_step
           
      event({:build_succeeded=>{}})
    end
    
    it "associates build errors with the right build step" do
      assume_build_started

      event({:build_step=>
        {:type=>"CompileC",
         :arguments=>
          ["build/ExampleProject.build/Release-iphoneos/ExampleProject.build/Objects-normal/armv7/main.o",
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
         
      reporter.build.last_step.should have(1).errors
    end
    
    it "associates build step command errors with the right build step" do
      assume_build_started

      event({:build_step=>
        {:type=>"CompileC",
         :arguments=>
          ["build/ExampleProject.build/Release-iphoneos/ExampleProject.build/Objects-normal/armv7/main.o",
           "ExampleProject/AppDelegate.m",
           "normal",
           "armv7",
           "objective-c",
           "com.apple.compilers.llvm.clang.1_0.compiler"]}})
           
      event({:build_error_detected=>
        {:command => "/bin/sh",
         :exit_code => 1}})
         
      reporter.build.last_step.should have(1).errors
    end
    
    it "notifies it's delegate that the build has finished when it is successful" do
      assume_build_started
      delegate.should_receive(:build_finished).with(reporter.build)
      event({:build_succeeded=>{}})
    end
    
    it "notifies it's delegate that the build has finished when it fails" do
      assume_build_started
      delegate.should_receive(:build_finished).with(reporter.build)
      event({:build_failed=>{}})
    end
    
    it "tracks the time a build takes" do
      Timecop.travel(Chronic.parse("10 seconds ago")) do
        event({:build_started=>
          {:target=>"ExampleProject",
           :project=>"ExampleProject",
           :configuration=>"Release",
           :default=>true}})
           
        Timecop.travel(Chronic.parse("5 seconds from now")) do
          event({:build_succeeded=>{}})
        end
      end
      
      reporter.build.duration.should be_within(0.01).of(5)
    end
    
    it "tracks any environment variables reported by the build" do
      assume_build_started
      event({:build_env_variable_detected=>["TEST_AFTER_BUILD", "YES"]})
      reporter.build.environment["TEST_AFTER_BUILD"].should == "YES"
    end
  end
  
  context "once a build has started" do
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
  
  context "once a simple, successful build has finished" do
    before do
      event({:build_started=>
        {:target=>"ExampleProject",
         :project=>"ExampleProject",
         :configuration=>"Release",
         :default=>true}})
         
      event({:build_step=>
        {:type=>"CpResource",
         :arguments=>
          ["/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS5.0.sdk/ResourceRules.plist",
           "build/Release-iphoneos/ExampleProject.app/ResourceRules.plist"]}})
           
      event({:build_step=>
        {:type=>"ProcessInfoPlistFile",
         :arguments=>
          ["build/Release-iphoneos/ExampleProject.app/Info.plist",
           "ExampleProject/ExampleProject-Info.plist"]}})
           
      event({:build_step=>
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
    
    it "reports the total number of completed build steps" do
      reporter.build.should have(3).steps_completed
    end
    
    it "reports that the build is not running" do
      reporter.build.should_not be_running
    end
    
    it "reports that the build is finished" do
      reporter.build.should be_finished
    end
  end
  
  context "once a simple, failed build has finished" do
    before do
      event({:build_started=>
        {:target=>"ExampleProject",
         :project=>"ExampleProject",
         :configuration=>"Release",
         :default=>true}})

      event({:build_step=>
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
      
      event({:build_step=>
        {:type=>"CompileC",
         :arguments=>
          ["build/ExampleProject.build/Release-iphoneos/ExampleProject.build/Objects-normal/armv7/AppDelegate.o",
           "ExampleProject/AppDelegate.m",
           "normal",
           "armv7",
           "objective-c",
           "com.apple.compilers.llvm.clang.1_0.compiler"]}})
           
      event({:build_failed=>{}})
      
      event({:build_step_failed=>
        {:type=>"CompileC",
         :arguments=>
          ["build/ExampleProject.build/Release-iphoneos/ExampleProject.build/Objects-normal/armv7/AppDelegate.o",
           "ExampleProject/AppDelegate.m",
           "normal",
           "armv7",
           "objective-c",
           "com.apple.compilers.llvm.clang.1_0.compiler"]}})
    end
    
    it_behaves_like "any build"
    
    it "reports that the build was a failure" do
      reporter.build.should be_failed
    end
    
    it "reports the total number of completed build steps" do
      reporter.build.should have(2).steps_completed
    end
    
    it "reports the total number of failed build steps" do
      reporter.build.should have(1).failed_steps
      reporter.build.failed_steps.first.tap do |step|
        step.type.should == "CompileC"
      end
    end
    
    it "reports the errors for each failed build step" do
      reporter.build.failed_steps.first.should have(1).errors
      reporter.build.failed_steps.first.errors.first.tap do |error|
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
      if params.is_a?(Hash)
        reporter.send(message, params)
      else
        reporter.send(message, *params)
      end
    else
      reporter.send(message)
    end
  end
  
  def assume_build_started
    event({:build_started=>
      {:target=>"ExampleProject",
       :project=>"ExampleProject",
       :configuration=>"Release",
       :default=>true}})
  end
end
