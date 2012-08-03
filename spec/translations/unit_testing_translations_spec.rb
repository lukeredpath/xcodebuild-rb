require 'spec_helper'

describe XcodeBuild::Translations::UnitTesting do
  let(:delegate)    { mock('delegate', :respond_to? => true) }
  let(:translator)  { XcodeBuild::OutputTranslator.new(delegate, :ignore_global_translations => true) }
  let(:translation) { translator.translations[0] }

  before do
    translator.use_translation XcodeBuild::Translations::UnitTesting

    delegate_should_respond_to(:beginning_translation_of_line)
    delegate.stub(:beginning_translation_of_line).and_return(true)

    translator.should have(1).translations
  end

  context "once a build start has been detected" do
    before do
      translation.stub(:building?).and_return(true)
    end

    it "notifies build failed and explanation if the RunUnitTests script has not been fixed" do
      delegate.should_receive(:build_error_detected) do |hash|
        hash[:file].should == "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/Tools/Tools/RunPlatformUnitTests"
        hash[:line].should == 95
        hash[:char].should == 0
        hash[:message].should =~ /Skipping tests; the iPhoneSimulator platform does not currently support application-hosted tests \(TEST_HOST set\)\./
        hash[:message].should =~ /xcodebuild-rb note\:/
      end
      translator << "\n\n\n"
      translator << "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/Tools/Tools/RunPlatformUnitTests:95: warning: Skipping tests; the iPhoneSimulator platform does not currently support application-hosted tests (TEST_HOST set)."
    end

    it "notifies build error if a test fails" do

      delegate.stub(:test_step_started)
      delegate.stub(:test_step)

      delegate.should_receive(:build_error_detected) do |hash|
        hash[:file].should == "/Users/chris/Projects/blah/blah/BlahTests/BlahTests.m"
        hash[:line].should == 31
        hash[:char].should == 0
        hash[:message].should == "-[BlahTests testExample] : Expected <2>, but was <1>"
      end

      translator << "\n\n\n"
      translator << "Test Case '-[BlahTests testExample]' started."
      translator << "/Users/chris/Projects/blah/blah/BlahTests/BlahTests.m:31: error: -[BlahTests testExample] : Expected <2>, but was <1>"
      translator << "Test Case '-[BlahTests testExample]' failed (0.000 seconds)."
    end

    it "notifies build warning for 'Unknown Device Type.'" do

      delegate.should_receive(:build_warning_detected) do |hash|
        hash[:file].should be_nil
        hash[:line].should == 0
        hash[:char].should == 0
        hash[:message].should =~ /Unknown Device Type/
      end
      translator << "\n\n\n"
      translator << "2012-07-23 15:46:33.589 Blah[23806:11603] Unknown Device Type. Using UIUserInterfaceIdiomPhone based on screen size"
    end

    it "notifies build error and explanation for 'Terminating since there is no workspace.'" do

      delegate.should_receive(:build_error_detected) do |hash|
        hash[:file].should be_nil
        hash[:line].should == 0
        hash[:char].should == 0
        hash[:message].should =~ /Terminating since there is no workspace/
        hash[:message].should =~ /xcodebuild-rb note\:/
      end

      translator << "\n\n\n"
      translator << "Terminating since there is no workspace."
    end

    it "shows test case started messages" do

      delegate.should_receive(:test_step_started) do |hash|
        hash[:message].should == "Test Case '-[BlahTests testExample]' started."
      end

      translator << "\n\n\n"
      translator << "Test Case '-[BlahTests testExample]' started."
    end

    it "shows test case messages" do

      delegate.should_receive(:test_step) do |hash|
        hash[:message].should == "Test Case '-[BlahTests testExample]' failed for some reason."
      end

      translator << "\n\n\n"
      translator << "Test Case '-[BlahTests testExample]' failed for some reason."
    end
  end
end