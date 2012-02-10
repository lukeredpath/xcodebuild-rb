require 'spec_helper'

describe XcodeBuild::Translations::Building do
  let(:delegate)    { mock('delegate', :respond_to? => true) }
  let(:translator)  { XcodeBuild::OutputTranslator.new(delegate, :ignore_global_translations => true) }
  let(:translation) { translator.translations[0] }
  
  before do
    translator.use_translation XcodeBuild::Translations::Building
    
    delegate_should_respond_to(:beginning_translation_of_line)
    delegate.stub(:beginning_translation_of_line).and_return(true)
    
    translator.should have(1).translations
  end
  
  context "before it detects that a build has started" do
    it "reports that it is not building" do
      translation.should_not be_building
    end
    
    it "notifies the delegate of the start of a build with the default configuration" do
      delegate.should_receive(:build_started).with(
                :target => "ExampleProject",
               :project => "ExampleProject.xcodeproj",
         :configuration => "Release",
               :default => true
      )
      translator << "=== BUILD NATIVE TARGET ExampleProject OF PROJECT ExampleProject.xcodeproj WITH THE DEFAULT CONFIGURATION (Release) ==="
    end
    
    it "notifies the delegate of the start of a build with a non-default configuration" do
      delegate.should_receive(:build_started).with(
                :target => "ExampleProject",
               :project => "ExampleProject.xcodeproj",
         :configuration => "Debug",
               :default => false
      )
      translator << "=== BUILD NATIVE TARGET ExampleProject OF PROJECT ExampleProject.xcodeproj WITH THE CONFIGURATION Debug ==="
    end

    it "treats :build_started as a required delegate message and raise if it doesn't respond" do
      delegate_should_not_respond_to(:build_started)
      lambda { 
        translator << "=== BUILD NATIVE TARGET ExampleProject OF PROJECT ExampleProject.xcodeproj WITH THE CONFIGURATION Debug ==="

      }.should raise_error(XcodeBuild::OutputTranslator::MissingDelegateMethodError)
    end
  end
  
  context "when translating a built started line" do
    it "handles hyphens in the target name" do
      delegate.should_receive(:build_started).with(
                :target => "ExampleProject-Test",
               :project => "ExampleProject.xcodeproj",
         :configuration => "Release",
               :default => true
      )
      translator << "=== BUILD NATIVE TARGET ExampleProject-Test OF PROJECT ExampleProject.xcodeproj WITH THE DEFAULT CONFIGURATION (Release) ==="
    end
  end
  
  context "once a build start has been detected" do
    before do
      translation.stub(:building?).and_return(true)
    end
    
    it "notifies the delegate of a single build step" do
      delegate.should_receive(:build_step).with(
             :type => "CodeSign", 
        :arguments => ["build/Debug-iphoneos/ExampleProject.app"]
      )
      translator << "\n"
      translator << "CodeSign build/Debug-iphoneos/ExampleProject.app"
    end

    it "treats :build_step as an optional delegate message" do
      delegate_should_not_respond_to(:build_step)
      delegate.should_not_receive(:build_step)
      translator << "\n"
      translator << "CodeSign build/Debug-iphoneos/ExampleProject.app"
    end

    it "notifies the delegate when the build failed" do
      delegate.should_receive(:build_failed)
      translator << "\n\n\n"
      translator << "** BUILD FAILED **"
    end

    it "treats :build_failed as a required delegate message and raise if it doesn't respond" do
      delegate_should_not_respond_to(:build_failed)
      lambda { 
        translator << "** BUILD FAILED **"

      }.should raise_error(XcodeBuild::OutputTranslator::MissingDelegateMethodError)
    end

    it "notifies the delegate when the build succeeded" do
      delegate.should_receive(:build_succeeded)
      translator << "\n\n\n"
      translator << "** BUILD SUCCEEDED **"
    end

    it "treats :build_succeeded as a required delegate message and raise if it doesn't respond" do
      delegate_should_not_respond_to(:build_succeeded)
      lambda { 
        translator << "** BUILD SUCCEEDED **"

      }.should raise_error(XcodeBuild::OutputTranslator::MissingDelegateMethodError)
    end

    it "notifies the delegate of build step failures" do
      delegate.should_receive(:build_step_failed).with(
             :type => "CodeSign", 
        :arguments => ["build/Debug-iphoneos/ExampleProject.app"]
      )
      translator << "The following build commands failed:"
      translator << "\tCodeSign build/Debug-iphoneos/ExampleProject.app"
      translator << "(2 failures)"
    end

    it "treats :build_step_failed as an optional delegate message" do
      delegate_should_not_respond_to(:build_step_failed)
      delegate.should_not_receive(:build_step_failed)
      translator << "The following build commands failed:"
      translator << "\tCodeSign build/Debug-iphoneos/ExampleProject.app"
    end

    it "notifies the delegate of errors that occur throughout the build" do
      delegate.should_receive(:build_error_detected).with(
             :file => "/ExampleProject/main.m", 
             :line => 16,
             :char => 42,
          :message => "expected ';' after expression [1]"
      )
      translator << "/ExampleProject/main.m:16:42: error: expected ';' after expression [1]"
    end

    it "notifies the delegate of errors for different build steps" do
      delegate.should_receive(:build_error_detected).with(
             :file => "/ExampleProject/main.m", 
             :line => 16,
             :char => 42,
          :message => "expected ';' after expression [1]"
      )

      translator << "CompileC ExampleProject/main.m normal"
      translator << "/ExampleProject/main.m:16:42: error: expected ';' after expression [1]"
      translator << "1 error generated."
    end

    it "notifies the delegate of multiple errors for the same build step" do
      delegate.should_receive(:build_error_detected).with(
             :file => "/ExampleProject/main.m", 
             :line => 16,
             :char => 42,
          :message => "expected ';' after expression [1]"
      ).twice

      translator << "CompileC ExampleProject/main.m normal"
      translator << "/ExampleProject/main.m:16:42: error: expected ';' after expression [1]"
      translator << ""
      translator << "/ExampleProject/main.m:16:42: error: expected ';' after expression [1]"
      translator << ""
      translator << "2 errors generated."
    end

    it "notifies the delegate of errors that occur when a command within a step fails" do
      delegate.should_receive(:build_error_detected).with(
          :command => "/bin/sh",
        :exit_code => 1
      )
      translator << "Command /bin/sh failed with exit code 1"
    end
    
    it "notifies the delegate of warnings" do
      delegate.should_receive(:build_warning_detected).with(
             :file => "/ExampleProject/main.m", 
             :line => 16,
             :char => 42,
          :message => "'foo:' is deprecated"
      )
      translator << "CompileC ExampleProject/main.m normal"
      translator << "/ExampleProject/main.m:16:42: warning: 'foo:' is deprecated"
      translator << "1 warning generated."
    end

    it "treats :build_error_detected as an optional delegate message" do
      delegate_should_not_respond_to(:build_error_detected)
      delegate.should_not_receive(:build_error_detected)
      translator << "/ExampleProject/main.m:16:42: error: expected ';' after expression [1]"
    end
    
    it "treats :build_warning_detected as an optional delegate message" do
      delegate_should_not_respond_to(:build_warning_detected)
      delegate.should_not_receive(:build_warning_detected)
      translator << "/ExampleProject/main.m:16:42: warning: expected ';' after expression [1]"
    end
    
    it "notifies the delegate of any environment variables that the build outputs" do
      delegate.should_receive(:build_env_variable_detected).with("ARCHS", "armv7")
      translator << "   setenv ARCHS armv7"
    end
    
    it "treats :build_env_variable_detected as an optional delegate message" do
      delegate_should_not_respond_to(:build_env_variable_detected)
      delegate.should_not_receive(:build_env_variable_detected)
      translator << "   setenv ARCHS armv7"
    end
  end
end
