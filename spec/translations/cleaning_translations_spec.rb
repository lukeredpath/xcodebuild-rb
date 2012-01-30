require 'spec_helper'

describe XcodeBuild::OutputTranslator do
  let(:delegate)   { mock('delegate', :respond_to? => true) }
  let(:translator) { XcodeBuild::OutputTranslator.new(delegate, ignore_global_translations: true) }
  let(:translation) { translator.translations[0] }

  before do
    translator.use_translation XcodeBuild::Translations::Cleaning

    delegate_should_respond_to(:beginning_translation_of_line)
    delegate.stub(:beginning_translation_of_line).and_return(true)

    translator.should have(1).translations
  end

  context "before it detects that a build has started" do
    it "reports that it is not cleaning" do
      translation.should_not be_cleaning
    end

    it "notifies the delegate of the start of a clean with the default configuration" do
      delegate.should_receive(:clean_started).with(
                target: "ExampleProject",
               project: "ExampleProject",
         configuration: "Release",
               default: true
      )
      translator << "=== CLEAN NATIVE TARGET ExampleProject OF PROJECT ExampleProject WITH THE DEFAULT CONFIGURATION (Release) ==="
    end

    it "notifies the delegate of the start of a clean with a non-default configuration" do
      delegate.should_receive(:clean_started).with(
                target: "ExampleProject",
               project: "ExampleProject",
         configuration: "Debug",
               default: false
      )
      translator << "=== CLEAN NATIVE TARGET ExampleProject OF PROJECT ExampleProject WITH THE CONFIGURATION Debug ==="
    end

    it "treats :clean_started as a required delegate message and raise if it doesn't respond" do
      delegate_should_not_respond_to(:clean_started)
      -> {
        translator << "=== CLEAN NATIVE TARGET ExampleProject OF PROJECT ExampleProject WITH THE CONFIGURATION Debug ==="

      }.should raise_error(XcodeBuild::OutputTranslator::MissingDelegateMethodError)
    end
  end

  context "once a clean start has been detected" do
    before do
      translation.stub(:cleaning?).and_return(true)
    end

    it "notifies the delegate of a single clean action" do
      delegate.should_receive(:clean_action).with(
             type: "Clean.Remove",
        arguments: ["clean", "build/Release-iphoneos/ExampleProject.app"]
      )
      translator << "\n"
      translator << "Clean.Remove clean build/Release-iphoneos/ExampleProject.app"
    end

    it "notifies the delegate when the clean succeeded" do
      delegate.should_receive(:clean_succeeded)
      translator << "\n\n\n"
      translator << "** CLEAN SUCCEEDED **"
    end

    it "treats :clean_succeeded as a required delegate message and raise if it doesn't respond" do
      delegate_should_not_respond_to(:clean_succeeded)
      -> {
        translator << "** CLEAN SUCCEEDED **"

      }.should raise_error(XcodeBuild::OutputTranslator::MissingDelegateMethodError)
    end

    it "notifies the delegate of clean action failures" do
      delegate.should_receive(:clean_action_failed).with(
             type: "Clean.Remove",
        arguments: ["clean", "build/Release-iphoneos/ExampleProject.app"]
      )
      translator << "The following build commands failed:"
      translator << "\tClean.Remove clean build/Release-iphoneos/ExampleProject.app"
      translator << "(1 failure)"
    end

    it "treats :clean_action_failed as an optional delegate message" do
      delegate_should_not_respond_to(:clean_action_failed)
      delegate.should_not_receive(:clean_action_failed)
      translator << "The following build commands failed:"
      translator << "\tClean.Remove clean build/Release-iphoneos/ExampleProject.app"
      translator << "(1 failure)"
    end

    it "notifies the delegate of errors for different clean actions" do
      delegate.should_receive(:clean_error_detected).with(
          message: "Error Domain=NSCocoaErrorDomain Code=513 ExampleProject couldn't be removed"
      )

      translator << "Clean.Remove clean build/Release-iphoneos/ExampleProject.app"
      translator << "error: Error Domain=NSCocoaErrorDomain Code=513 ExampleProject couldn't be removed"
      translator << "Command builtin-rm failed with exit code -1"
      translator << ""
    end

    it "notifies the delegate of multiple errors for the same clean action" do
      delegate.should_receive(:clean_error_detected).with(
          message: "Error Domain=NSCocoaErrorDomain Code=513 ExampleProject couldn't be removed"
      ).twice
    
      translator << "Clean.Remove clean build/Release-iphoneos/ExampleProject.app"
      translator << "error: Error Domain=NSCocoaErrorDomain Code=513 ExampleProject couldn't be removed"
      translator << "error: Error Domain=NSCocoaErrorDomain Code=513 ExampleProject couldn't be removed"
      translator << "Command builtin-rm failed with exit code -1"
      translator << ""
    end
    
    it "treats :clean_error_detected as an optional delegate message" do
      delegate_should_not_respond_to(:clean_error_detected)
      delegate.should_not_receive(:clean_error_detected)

      translator << "Clean.Remove clean build/Release-iphoneos/ExampleProject.app"
      translator << "error: Error Domain=NSCocoaErrorDomain Code=513 ExampleProject couldn't be removed"
      translator << "Command builtin-rm failed with exit code -1"
      translator << ""
    end
  end
end
