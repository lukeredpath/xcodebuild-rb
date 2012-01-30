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
      
      def clean_step(params)
        if clean.last_step
          notify :clean_step_finished, clean.last_step
        end

        clean.add_step(params)

        notify :clean_step_started, clean.last_step
      end
      
      def clean_error_detected(params)
        clean.last_step.add_error(params)
      end
      
      def clean_succeeded
        clean.success!
        clean_finished
      end
      
      def clean_failed
        clean.failure!
        clean_finished
      end
      
      def clean_step_failed(params)
        if step = clean.step_with_params(params)
          step.failed = true
        end
      end
      
      private
      
      def clean_finished
        if clean.last_step
          notify :clean_step_finished, clean.last_step
        end
        
        notify :clean_finished, clean
      end
      
      class Clean < BuildAction
      end
    end
  end
end
