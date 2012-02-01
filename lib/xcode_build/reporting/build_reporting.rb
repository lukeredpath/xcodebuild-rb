require 'ostruct'

module XcodeBuild
  module Reporting
    module BuildReporting
      def self.included(klass)
        klass.instance_eval do
          attr_reader :build
        end
      end
      
      def build_started(params)
        @build = Build.new(params)
        notify :build_started, @build
      end

      def build_step(params)
        if @build.last_step
          notify :build_step_finished, @build.last_step
        end

        @build.add_step(params)

        notify :build_step_started, @build.last_step
      end

      def build_error_detected(params)
        @build.last_step.add_error(params)
      end
      
      def build_env_variable_detected(key, value)
        @build.set_environment_variable(key, value)
      end

      def build_succeeded
        @build.success!
        build_finished
      end

      def build_failed
        @build.failure!
        build_finished
      end

      def build_step_failed(params)
        if step = @build.step_with_params(params)
          step.failed = true
        end
      end
      
      private

      def build_finished
        if @build.last_step
          notify :build_step_finished, @build.last_step
        end

        notify :build_finished, @build
      end
      
      class Build < BuildAction
        attr_reader :environment
        
        def initialize(metadata)
          super(metadata)
          @environment = {}
        end
        
        def set_environment_variable(key, value)
          @environment[key] = value
        end
      end
    end
  end
end
