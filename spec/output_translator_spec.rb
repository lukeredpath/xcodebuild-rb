require 'spec_helper'

describe XcodeBuild::OutputTranslator do
  let(:delegate)   { mock('delegate') }
  let(:translator) { XcodeBuild::OutputTranslator.new(delegate) }
  
  before do
    delegate.stub(:respond_to?).with(anything).and_return(true)
    delegate_should_respond_to(:beginning_translation_of_line)
    delegate.stub(:beginning_translation_of_line).and_return(true)
  end
  
  it "notifies the delegate of each line received (to assist additional processing elsewhere)" do
    delegate.should_receive(:beginning_translation_of_line).with("the line")
    translator << "the line"
  end
  
  it "treats :beginning_translation_of_line as an optional delegate message" do
    delegate_should_not_respond_to(:beginning_translation_of_line)
    delegate.should_not_receive(:beginning_translation_of_line)
    translator << "anything"
  end
  
  it "notifies the delegate of the start of a build with the default configuration" do
    delegate.stub(:beginning_translation_of_line)
    delegate.should_receive(:build_started).with(
              target: "ExampleProject",
             project: "ExampleProject",
       configuration: "Release",
             default: true
    )
    translator << "=== BUILD NATIVE TARGET ExampleProject OF PROJECT ExampleProject WITH THE DEFAULT CONFIGURATION (Release) ==="
  end
  
  it "notifies the delegate of the start of a build with a non-default configuration" do
    delegate.stub(:beginning_translation_of_line)
    delegate.should_receive(:build_started).with(
              target: "ExampleProject",
             project: "ExampleProject",
       configuration: "Debug",
             default: false
    )
    translator << "=== BUILD NATIVE TARGET ExampleProject OF PROJECT ExampleProject WITH THE CONFIGURATION Debug ==="
  end
  
  it "treats :build_started as a required delegate message and raise if it doesn't respond" do
    delegate_should_not_respond_to(:build_started)
    -> { 
      translator << "=== BUILD NATIVE TARGET ExampleProject OF PROJECT ExampleProject WITH THE CONFIGURATION Debug ==="
      
    }.should raise_error(XcodeBuild::OutputTranslator::MissingDelegateMethodError)
  end
  
  it "notifies the delegate of a single build action" do
    delegate.stub(:beginning_translation_of_line)
    delegate.should_receive(:build_action).with(
           type: "CodeSign", 
      arguments: ["build/Debug-iphoneos/ExampleProject.app"]
    )
    translator << "\n"
    translator << "CodeSign build/Debug-iphoneos/ExampleProject.app"
  end
  
  it "treats :beginning_translation_of_line as an optional delegate message" do
    delegate_should_not_respond_to(:build_action)
    delegate.should_not_receive(:build_action)
    translator << "\n"
    translator << "CodeSign build/Debug-iphoneos/ExampleProject.app"
  end
  
  it "notifies the delegate when the build failed" do
    delegate.stub(:beginning_translation_of_line)
    delegate.should_receive(:build_failed)
    translator << "\n\n\n"
    translator << "** BUILD FAILED **"
  end
  
  it "treats :build_failed as a required delegate message and raise if it doesn't respond" do
    delegate_should_not_respond_to(:build_failed)
    -> { 
      translator << "** BUILD FAILED **"
      
    }.should raise_error(XcodeBuild::OutputTranslator::MissingDelegateMethodError)
  end
  
  it "notifies the delegate when the build succeeded" do
    delegate.stub(:beginning_translation_of_line)
    delegate.should_receive(:build_succeeded)
    translator << "\n\n\n"
    translator << "** BUILD SUCCEEDED **"
  end
  
  it "treats :build_succeeded as a required delegate message and raise if it doesn't respond" do
    delegate_should_not_respond_to(:build_succeeded)
    -> { 
      translator << "** BUILD SUCCEEDED **"
      
    }.should raise_error(XcodeBuild::OutputTranslator::MissingDelegateMethodError)
  end
  
  it "notifies the delegate of build action failures" do
    delegate.should_receive(:build_action_failed).with(
           type: "CodeSign", 
      arguments: ["build/Debug-iphoneos/ExampleProject.app"]
    )
    translator << "The following build commands failed:"
    translator << "CodeSign build/Debug-iphoneos/ExampleProject.app"
  end
  
  it "treats :build_action_failed as an optional delegate message" do
    delegate_should_not_respond_to(:build_action_failed)
    delegate.should_not_receive(:build_action_failed)
    translator << "The following build commands failed:"
    translator << "CodeSign build/Debug-iphoneos/ExampleProject.app"
  end
  
  private
  
  def delegate_should_respond_to(method)
    mock_should_respond?(delegate, method, true)
  end
  
  def delegate_should_not_respond_to(method)
    mock_should_respond?(delegate, method, false)
  end
  
  def mock_should_respond?(mock, method, should_respond)
    mock.stub(:respond_to?).with(method).and_return(should_respond)
  end
end
