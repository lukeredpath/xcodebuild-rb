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
    end

    def build_succeeded
      @build.succeed!
    end

    def build_failed
    end

    def build_action_failed(params)
    end
    
    private
    
    class Build
      attr_reader :actions_completed
      
      def initialize(metadata)
        @successful = false
        @actions_completed = []
        @metadata = metadata
        @finished = false
      end
      
      def add_action(params)
        @actions_completed << params
      end
      
      def succeed!
        @successful = true
        @finished = true
      end

      def successful?
        @successful
      end
      
      def finished?
        @finished
      end
      
      def running?
        !@finished
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
  end
end
