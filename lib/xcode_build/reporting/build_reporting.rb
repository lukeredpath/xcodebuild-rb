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
        notify :build_started, build
      end

      def build_step(params)
        if build.last_step
          notify :build_step_finished, build.last_step
        end

        build.add_step(params)

        notify :build_step_started, build.last_step
      end

      def build_error_detected(params)
        build.last_step.add_error(params)
      end
      
      def build_warning_detected(params)
        build.add_warning(params)
      end
      
      def build_env_variable_detected(key, value)
        build.set_environment_variable(key, value)
      end

      def build_succeeded(archive_or_build)
        build.label = archive_or_build
        
        # for some reason, archive reports a success even if there was an error
        if build.has_errors?
          build.failure!
        else
          build.success!
        end
        
        build_finished
      end

      def build_failed(archive_or_build)
        build.label = archive_or_build
        build.failure!
        build_finished
      end

      def build_step_failed(params)
        if step = build.step_with_params(params)
          step.failed = true
        end
      end
      
      private

      def build_finished
        if build.last_step
          notify :build_step_finished, build.last_step
        end

        notify :build_finished, build
      end
      
      class Build < BuildAction
        attr_reader :environment, :warnings
        attr_writer :label
        
        def initialize(metadata)
          super(metadata)
          @environment = {}
          @warnings = []
          @label = "Build"
        end
        
        def set_environment_variable(key, value)
          @environment[key] = value
        end
        
        def target_build_directory
          @environment["TARGET_BUILD_DIR"]
        end
        
        def add_warning(params)
          @warnings << Warning.new(params)
        end
        
        private
        
        class Warning < OpenStruct
          def warning_detail
            "in #{err.file}:#{err.line.to_s}"
          end
        end
      end
    end
  end
end
