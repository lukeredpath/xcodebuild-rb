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

TERMINATING_SINCE_THERE_IS_NO_WORKSPACE_EXPLANATION = <<EXPLANATION
xcodebuild-rb note: Make sure that you have a workspace set.
You might also need to explicitly specify the SDK.
EXPLANATION

      def attempt_to_translate(line)
        case line
          when /^(.*)\:(.*)\: warning\: (Skipping tests; .*)$/
            notify_build_error($1, $2, 0, "#{$3}\n#{RUN_UNIT_TESTS_ERROR}")
          when /^(.*) (Unknown Device Type.*)$/
            notify_build_warning(nil, 0, 0, $2)
          when /^(Terminating since .*)$/
            notify_build_error(nil, 0, 0, "#{$1}\n#{TERMINATING_SINCE_THERE_IS_NO_WORKSPACE_EXPLANATION}")
          when /^Test Case .*started\.$/
            puts
            puts line
            #notify_delegate(:test_step_started, :args => [{
            #                                          :message => line
            #                                      }])
          when /^Test Case .*$/
            puts line
            #notify_delegate(:test_step, :args => [{
            #                                          :message => line
            #                                      }])
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

      def notify_build_warning(file, line, char, message)
        notify_delegate(:build_warning_detected, :args => [{
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