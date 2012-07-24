module XcodeBuild
  module Translations
    module UnitTesting

RUN_UNIT_TESTS_ERROR = <<EXPLANATION
xcodebuild-rb note: This message is caused by a limitation in
Apple's Xcode RunUnitScripts shell script. In order to run unit
tests from the command line you need to edit this script as
described here:
http://www.stewgleadow.com/blog/2012/02/09/running-ocunit-and-kiwi-tests-on-the-command-line/
EXPLANATION

      def attempt_to_translate(line)
        case line
          when /^(.*)\:(.*)\: warning\: (Skipping tests; .*)$/
            notify_build_error($1, $2, 0, "#{$3}\n#{RUN_UNIT_TESTS_ERROR}")
          when /^Test Case '(.*)' started\.$/
            @in_tests = true
          when /(.*)\:(\d+)\: error\: (.*)/
            notify_build_error($1, $2, 0, $3)
        end
      end

      def notify_build_error(file, line, char, message)
        notify_delegate(:build_error_detected, :args => [{
                                                               :file => file,
                                                               :line => line.to_i,
                                                               :char => char.to_i,
                                                               :message => message
                                                           }])
      end

    end

    register_translation :unit_testing, UnitTesting
  end
end