require 'spec_helper'

describe XcodeBuild::Reporting::CleanReporting do
  let(:reporter) { XcodeBuild::Reporter.new }
  
  shared_examples_for "any clean" do
    it "reports the clean target" do
      reporter.clean.target.should == "ExampleProject"
    end
    
    it "reports the project name" do
      reporter.clean.project_name.should == "ExampleProject"
    end
    
    it "reports the clean configuration" do
      reporter.clean.configuration.should == "Release"
    end
    
    it "reports if the clean configuration was the default" do
      reporter.clean.should be_default_configuration
    end
  end
  
  context "when receiving events" do
    let(:delegate) { mock('reporter delegate').as_null_object }
    
    before do
      reporter.delegate = delegate
      
      # let's assume it responds to all delegate methods
      delegate.stub(:respond_to?).with(anything).and_return(true)
    end
    
    it "notifies it's delegate that a clean has started" do
      delegate.should_receive(:clean_started).with instance_of(XcodeBuild::Reporting::CleanReporting::Clean)
      
      event({:clean_started=>
        {:target=>"ExampleProject",
         :project=>"ExampleProject",
         :configuration=>"Release",
         :default=>true}})
    end
    
    it "notifies it's delegate when a clean action begins" do
      assume_clean_started
      
      delegate.should_receive(:clean_action_started).with instance_of(XcodeBuild::Reporting::CleanReporting::CleanAction)
      
      event({:clean_action=>
        {:type=>"Clean.Remove",
         :arguments=>
          ["clean",
           "build/Release-iphoneos/ExampleProject.app"]}})
    end
    
    it "notifies it's delegate when a previous clean action finishes" do
      assume_clean_started

      event({:clean_action=>
        {:type=>"Clean.Remove",
         :arguments=>
          ["clean",
           "build/Release-iphoneos/ExampleProject.app"]}})
           
      delegate.should_receive(:clean_action_finished).with reporter.clean.last_action
           
      event({:clean_action=>
        {:type=>"Clean.Remove",
         :arguments=>
          ["clean",
           "build/Release-iphoneos/ExampleProject.app"]}})
    end
    
    it "notifies it's delegate when the last clean action finishes and the clean is successful" do
      assume_clean_started

      event({:clean_action=>
        {:type=>"Clean.Remove",
         :arguments=>
          ["clean",
           "build/Release-iphoneos/ExampleProject.app"]}})
           
      delegate.should_receive(:clean_action_finished).with reporter.clean.last_action
           
      event({:clean_succeeded=>{}})
    end
    
    it "notifies it's delegate that the clean has finished when it is successful" do
      assume_clean_started
      delegate.should_receive(:clean_finished).with(reporter.clean)
      event({:clean_succeeded=>{}})
    end
    
    it "tracks the time a clean takes" do
      Timecop.travel(Chronic.parse("10 seconds ago")) do
        event({:clean_started=>
          {:target=>"ExampleProject",
           :project=>"ExampleProject",
           :configuration=>"Release",
           :default=>true}})
           
        Timecop.travel(Chronic.parse("5 seconds from now")) do
          event({:clean_succeeded=>{}})
        end
      end
      
      reporter.clean.duration.should be_within(0.01).of(5)
    end
  end
  
  context "once a clean has started" do
    before do
      event({:clean_started=>
        {:target=>"ExampleProject",
         :project=>"ExampleProject",
         :configuration=>"Release",
         :default=>true}})
    end
    
    it "reports that the clean is running" do
      reporter.clean.should be_running
    end
    
    it "reports that the clean is not finished" do
      reporter.clean.should_not be_finished
    end
  end
  
  context "once a simple, successful clean has finished" do
    before do
      event({:clean_started=>
        {:target=>"ExampleProject",
         :project=>"ExampleProject",
         :configuration=>"Release",
         :default=>true}})
         
      event({:clean_action=>
         {:type=>"Clean.Remove",
          :arguments=>
           ["clean",
            "build/Release-iphoneos/FileOne"]}})
           
      event({:clean_action=>
        {:type=>"Clean.Remove",
         :arguments=>
          ["clean",
           "build/Release-iphoneos/FileTwo"]}})
           
      event({:clean_succeeded=>{}})
    end
    
    it_behaves_like "any clean"
    
    it "reports that the clean was successful" do
      reporter.clean.should be_successful
    end
    
    it "reports the total number of completed clean actions" do
      reporter.clean.should have(2).actions_completed
    end
    
    it "reports that the clean is not running" do
      reporter.clean.should_not be_running
    end
    
    it "reports that the clean is finished" do
      reporter.clean.should be_finished
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
  
  def assume_clean_started
    event({:clean_started=>
      {:target=>"ExampleProject",
       :project=>"ExampleProject",
       :configuration=>"Release",
       :default=>true}})
  end
end
