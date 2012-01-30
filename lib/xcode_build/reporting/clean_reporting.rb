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
      
      def clean_succeeded
        if clean.last_action
          notify :clean_action_finished, clean.last_action
        end
        
        clean.success!
        
        notify :clean_finished, clean
      end
      
      private
      
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

          after_transition :running => :successful do |build|
            build.finished_at = Time.now
          end
        end
        
        def add_action(params)
          @actions_completed << CleanAction.new(params)
        end
        
        def last_action
          @actions_completed.last
        end
        
        def finished?
          successful?
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
        def initialize(metadata)
          @metadata = metadata
        end
        
        def has_errors?
          false
        end
        
        def ==(other_action)
          (other_action.type == type &&
           other_action.arguments == arguments)
        end
        
        def type
          @metadata[:type]
        end

        def arguments
          @metadata[:arguments]
        end
      end
    end
  end
end
