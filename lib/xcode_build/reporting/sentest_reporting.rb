require 'ostruct'

module XcodeBuild
  module Reporting
    module SentestReporting
      def tests_started
        @running_tests = true
        @test_suite_stack = []
      end
      
      def main_test_suite
        @test_suite_stack[0]
      end
      
      def current_test_suite
        @test_suite_stack.last
      end
      
      def test_suite_started(name)
        if @test_suite_stack.empty?
          @test_suite_stack.push TestSuite.new(name)
        else
          @test_suite_stack.push current_test_suite.add_test_suite(name) 
        end
      end
      
      def test_suite_finished(name)
        current_test_suite.finish!
        @test_suite_stack.pop unless @test_suite_stack.count == 1
      end
      
      def test_case_started(name)
        @current_test_case = current_test_suite.add_test_case(name)
      end
      
      def test_case_passed(name)
        @current_test_case.passed!
      end
      
      def test_case_failed(name)
        @current_test_case.failed!
      end

      class TestSuite
        attr_reader :name, :finished, :test_cases
        
        def initialize(name)
          @name = name
          @suites = []
          @test_cases = []
          @finished = false
        end
        
        def add_test_suite(name)
          @suites << TestSuite.new(name)
          @suites.last
        end
        
        def add_test_case(name)
          @test_cases << TestCase.new(name)
          @test_cases.last
        end
        
        def finish!
          @finished = true
        end
        
        def test_count
          @suites.inject(@test_cases.count) { |total, suite| suite.test_count + total }
        end
        
        def failure_count
          local_failures = @test_cases.select { |tc| tc.failed? }.count
          @suites.inject(local_failures) { |total, suite| suite.failure_count + total }
        end
      end
      
      class TestCase
        attr_reader :name
        
        def initialize(name)
          @name = name
          @result = :unknown
        end
        
        def passed!
          @result = :passed
        end
        
        def passed?
          @result == :passed
        end
        
        def failed!
          @result = :failed
        end
        
        def failed?
          @result == :failed
        end
      end
    end
  end
end
