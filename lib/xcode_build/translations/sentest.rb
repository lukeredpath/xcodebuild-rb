module XcodeBuild
  module Translations
    module Sentest
      def attempt_to_translate(line)
        case line
        when /^Run unit tests for architecture/
          @testing = true
          notify_delegate(:tests_started)
        when /^Run test suite (.*)/
          notify_delegate(:test_suite_started, :args => [{:name => $1}])
        when /^Run test case (.*)/
          notify_delegate(:test_case_started, :args => [{:name => $1}])
        when /^Test Case '-\[(\w+) (\w+)\]' (failed|passed)/
          notify_delegate("test_case_#{$3}", :args => [{:suite => $1, :name => $2}])
        when /^Test Suite '(.*)' finished/
          notify_delegate(:test_suite_finished, :args => [{:name => $1}])
        when /^(.*):(\d+): error: -\[(\w+) (\w+)\] : (.*)$/
          notify_delegate(:test_error, :args => [{
               :file => $1, 
               :line => $2.to_i,
              :suite => $3,
               :test => $4,
            :message => $5
          }])
        end
      end
      
      def testing?
        @testing
      end
    end
  end
end
