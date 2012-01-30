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

      def build_action(params)
        if @build.last_action
          notify :build_action_finished, @build.last_action
        end

        @build.add_action(params)

        notify :build_action_started, @build.last_action
      end

      def build_error_detected(params)
        @build.last_action.add_error(params)
      end

      def build_succeeded
        @build.success!
        build_finished
      end

      def build_failed
        @build.failure!
        build_finished
      end

      def build_action_failed(params)
        if action = @build.action_with_params(params)
          action.failed = true
        end
      end
      
      private

      def build_finished
        if @build.last_action
          notify :build_action_finished, @build.last_action
        end

        notify :build_finished, @build
      end
      
      class Build < Command
      end
    end
  end
end
