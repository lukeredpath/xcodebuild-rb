require 'spec_helper'

describe XcodeBuild::Translations::Sentest do
  let(:delegate)   { mock('delegate', :respond_to? => true) }
  let(:translator) { XcodeBuild::OutputTranslator.new(delegate, :ignore_global_translations => true) }
  let(:translation) { translator.translations[0] }

  before do
    translator.use_translation XcodeBuild::Translations::Sentest

    delegate_should_respond_to(:beginning_translation_of_line)
    delegate.stub(:beginning_translation_of_line).and_return(true)

    translator.should have(1).translations
  end

  context "before it detects a test run has started" do
    it "reports that it is not testing" do
      translation.should_not be_testing
    end
    
    it "notifies when the unit test suite starts running" do
      delegate.should_receive(:tests_started)
      translator << "Run unit tests for architecture 'i386'"
    end
  end
  
  context "once a test run has started" do
    before do
      delegate.stub(:tests_started)
      translator << "Run unit tests for architecture 'i386'"
    end
    
    it "reports that it is not testing" do
      translation.should be_testing
    end
    
    it "notifies when a test suite begins" do
      delegate.should_receive(:test_suite_started).with(:name => "ExampleProjectTests")
      translator << "Run test suite ExampleProjectTests"
    end
    
    it "notifies when a test case begins" do
      delegate.should_receive(:test_case_started).with(:name => "testSomething")
      translator << "Run test case testSomething"
    end
    
    it "notifies when a test case begins" do
      delegate.should_receive(:test_case_started).with(:name => "testSomething")
      translator << "Run test case testSomething"
    end
    
    it "notifies when a test case fails" do
      delegate.should_receive(:test_case_failed).with(:suite => 'ExampleProjectTests', :name => "testFailure")
      translator << "Test Case '-[ExampleProjectTests testFailure]' failed (0.000 seconds)."
    end
    
    it "notifies when a test case passes" do
      delegate.should_receive(:test_case_passed).with(:suite => 'ExampleProjectTests', :name => "testSomething")
      translator << "Test Case '-[ExampleProjectTests testSomething]' passed (0.000 seconds)."
    end
    
    it "notifies of errors that resulted in a test failure" do
      delegate.should_receive(:test_error).with(
             :file => "/ExampleProjectTests/ExampleProjectTests.m", 
             :line => 44,
            :suite => 'ExampleProjectTests',
             :test => 'testFailure',
          :message => "This is the test error message."
      )
      translator << "/ExampleProjectTests/ExampleProjectTests.m:44: error: -[ExampleProjectTests testFailure] : This is the test error message."
    end
    
    it "notifies when a test suite finishes" do
      delegate.should_receive(:test_suite_finished).with(:name => 'ExampleProjectTests')
      translator << "Test Suite 'ExampleProjectTests' finished at 2012-02-16 18:02:41 +0000."
    end
  end
end
