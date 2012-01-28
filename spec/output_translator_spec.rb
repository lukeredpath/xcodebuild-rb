require 'spec_helper'
require 'xcode_build/output_translator'

describe XcodeBuild::OutputTranslator do
  let(:delegate)   { mock('delegate') }
  let(:translator) { XcodeBuild::OutputTranslator.new(delegate) }
  
  it "notifies the delegate of the start of a build with the default configuration" do
    delegate.should_receive(:build_started).with(
              target: "ExampleProject",
             project: "ExampleProject",
       configuration: "Release",
             default: true
    )
    translator << "=== BUILD NATIVE TARGET ExampleProject OF PROJECT ExampleProject WITH THE DEFAULT CONFIGURATION (Release) ==="
  end
  
  it "notifies the delegate of the start of a build with a non-default configuration" do
    delegate.should_receive(:build_started).with(
              target: "ExampleProject",
             project: "ExampleProject",
       configuration: "Debug",
             default: false
    )
    translator << "=== BUILD NATIVE TARGET ExampleProject OF PROJECT ExampleProject WITH THE CONFIGURATION Debug ==="
  end
  
  it "notifies the delegate of a single build action" do
    delegate.should_receive(:build_action).with(
           type: "CodeSign", 
      arguments: ["build/Debug-iphoneos/ExampleProject.app"]
    )
    translator << "\n"
    translator << "CodeSign build/Debug-iphoneos/ExampleProject.app"
  end
  
  it "notifies the delegate when the build failed" do
    delegate.should_receive(:build_failed)
    translator << "\n\n\n"
    translator << "** BUILD FAILED **"
  end
  
  it "notifies the delegate when the build succeeded" do
    delegate.should_receive(:build_succeeded)
    translator << "\n\n\n"
    translator << "** BUILD SUCCEEDED **"
  end
end
