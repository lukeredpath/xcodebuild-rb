module XcodeBuild
  module Reporting
    module CleanReporting
      def self.included(klass)
        klass.instance_eval do
          attr_reader :clean
        end
      end
      
      def clean_started(params)
        @clean = Clean.new(params)
        notify :clean_started, @clean
      end
      
      def clean_action(params)
        if clean.last_action
          notify :clean_action_finished, clean.last_action
        end

        clean.add_action(params)

        notify :clean_action_started, clean.last_action
      end
      
      def clean_error_detected(params)
        clean.last_action.add_error(params)
      end
      
      def clean_succeeded
        clean.success!
        clean_finished
      end
      
      def clean_failed
        clean.failure!
        clean_finished
      end
      
      def clean_action_failed(params)
        if action = clean.action_with_params(params)
          action.failed = true
        end
      end
      
      private
      
      def clean_finished
        if clean.last_action
          notify :clean_action_finished, clean.last_action
        end
        
        notify :clean_finished, clean
      end
      
      class Clean < Command
      end
    end
  end
end
