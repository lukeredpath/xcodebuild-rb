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
      
      class Clean
        attr_reader :actions_completed
        attr_writer :finished_at
        
        def initialize(metadata)
          @metadata = metadata
          @actions_completed = []
          @started_at = Time.now
          super
        end
        
        state_machine :state, :initial => :running do
          event :success do
            transition :running => :successful
          end

          event :failure do
            transition :running => :failed
          end

          after_transition :running => [:successful, :failed] do |clean|
            clean.finished_at = Time.now
          end
        end
        
        def add_action(params)
          @actions_completed << CleanAction.new(params)
        end
        
        def last_action
          @actions_completed.last
        end
        
        def failed_actions
          @actions_completed.select { |a| a.failed? }
        end
        
        def action_with_params(params)
          @actions_completed.detect { |a| a == CleanAction.new(params) }
        end
        
        def finished?
          successful? || failed?
        end
        
        def duration
          return nil unless finished?
          @finished_at - @started_at
        end

        def project_name
          @metadata[:project]
        end

        def target
          @metadata[:target]
        end

        def configuration
          @metadata[:configuration]
        end

        def default_configuration?
          @metadata[:default]
        end
      end
      
      class CleanAction
        attr_reader :errors
        attr_writer :failed
        
        def initialize(metadata)
          @metadata = metadata
          @errors = []
        end
        
        def add_error(params)
          @errors << CleanError.new(params)
        end

        def has_errors?
          @errors.any?
        end
        
        def ==(other_action)
          (other_action.type == type &&
           other_action.arguments == arguments)
        end
        
        def failed?
          @failed
        end
        
        def type
          @metadata[:type]
        end

        def arguments
          @metadata[:arguments]
        end
      end
      
      class CleanError < OpenStruct
      end
    end
  end
end
