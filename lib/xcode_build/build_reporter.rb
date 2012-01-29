require 'state_machine'
require 'ostruct'

module XcodeBuild
  class BuildReporter
    attr_reader :build

    def build_started(params)
      @build = Build.new(params)
    end

    def build_action(params)
      @build.add_action(params)
    end

    def build_error_detected(params)
      @build.last_action.add_error(params)
    end

    def build_succeeded
      @build.success!
    end

    def build_failed
      @build.failure!
    end

    def build_action_failed(params)
      @build.action_with_params(params).failed = true
    end
    
    private
    
    class Build
      attr_reader :actions_completed
      
      def initialize(metadata)
        @actions_completed = []
        @metadata = metadata
        super
      end
      
      state_machine :state, :initial => :running do
        event :success do
          transition :running => :successful
        end
        
        event :failure do
          transition :running => :failed
        end
      end
      
      def add_action(params)
        @actions_completed << BuildAction.new(params)
      end
      
      def failed_actions
        @actions_completed.select { |a| a.failed? }
      end
      
      def action_with_params(params)
        @actions_completed.detect { |a| a == BuildAction.new(params) }
      end
      
      def last_action
        @actions_completed.last
      end
      
      def finished?
        successful? || failed?
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
    
    class BuildAction
      attr_accessor :failed
      attr_reader :errors
      
      def initialize(metadata)
        @metadata = metadata
        @errors = []
      end
      
      def add_error(params)
        @errors << BuildError.new(params)
      end
      
      def ==(other_action)
        (other_action.type == type &&
         other_action.args == args)
      end
      
      def type
        @metadata[:type]
      end
      
      def args
        @metadata[:args]
      end
      
      def failed?
        @failed
      end
    end
    
    class BuildError < OpenStruct
    end
  end
end
