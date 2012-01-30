require 'state_machine'
require 'ostruct'

module XcodeBuild
  class BuildReporter
    attr_reader :build
    attr_accessor :delegate
    
    def initialize(delegate = nil)
      @delegate = delegate
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
      @build.action_with_params(params).failed = true
    end
    
    private
    
    def build_finished
      if @build.last_action
        notify :build_action_finished, @build.last_action
      end
      
      notify :build_finished, @build
    end
    
    def notify(event, *args)
      return unless @delegate
      @delegate.send(event, *args) if @delegate.respond_to?(event)
    end
    
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
