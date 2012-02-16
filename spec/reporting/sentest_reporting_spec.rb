require 'spec_helper'

describe XcodeBuild::Reporting::SentestReporting do
  let(:reporter) { XcodeBuild::Reporter.new }

  example "a completely empty test suite has 0 tests, 0 failures" do
    event({:tests_started => []})
    event({:test_suite_started=>
      {:name=>"/Shortened/Path/ExampleProjectTests.octest(Tests)"}})
    event({:test_suite_started=>
      {:name=>"YourAppTests"}})
    event({:test_suite_finished=>
      {:name=>"YourAppTests"}})
    event({:test_suite_finished=>
      {:name=>"/Shortened/Path/ExampleProjectTests.octest(Tests)"}})
      
    reporter.main_test_suite.should_not be_nil
    reporter.main_test_suite.test_count.should == 0
    reporter.main_test_suite.failure_count.should == 0
  end
  
  example "a test suite with a single passing test has 1 tests, 0 failures" do
    event({:tests_started => []})
    event({:test_suite_started=>
      {:name=>"/Shortened/Path/ExampleProjectTests.octest(Tests)"}})
    event({:test_suite_started=>
      {:name=>"YourAppTests"}})
    event({:test_case_started=>
      {:name=>"testSomethingWorks"}})
    event({:test_case_passed=>
      {:name=>"testSomethingWorks"}})
    event({:test_suite_finished=>
      {:name=>"YourAppTests"}})
    event({:test_suite_finished=>
      {:name=>"/Shortened/Path/ExampleProjectTests.octest(Tests)"}})
      
    reporter.main_test_suite.should_not be_nil
    reporter.main_test_suite.test_count.should == 1
    reporter.main_test_suite.failure_count.should == 0
  end
  
  example "a test suite with a single failing test has 1 tests, 1 failures" do
    event({:tests_started => []})
    event({:test_suite_started=>
      {:name=>"/Shortened/Path/ExampleProjectTests.octest(Tests)"}})
    event({:test_suite_started=>
      {:name=>"YourAppTests"}})
    event({:test_case_started=>
      {:name=>"testSomethingWorks"}})
    event({:test_case_failed=>
      {:name=>"testSomethingWorks"}})
    event({:test_suite_finished=>
      {:name=>"YourAppTests"}})
    event({:test_suite_finished=>
      {:name=>"/Shortened/Path/ExampleProjectTests.octest(Tests)"}})
      
    reporter.main_test_suite.should_not be_nil
    reporter.main_test_suite.test_count.should == 1
    reporter.main_test_suite.failure_count.should == 1
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
