module XcodeBuild
  class BuildReporter
    attr_reader :build_actions_completed
    
    def initialize
      @build_successful = false
      @build_actions_completed = []
      @build_metadata = {}
    end
    
    def build_successful?
      @build_successful
    end
    
    def project_name
      @build_metadata[:project]
    end
    
    def build_target
      @build_metadata[:target]
    end
    
    def build_configuration
      @build_metadata[:configuration]
    end
    
    def was_default_build_configuration?
      @build_metadata[:default]
    end
    
    # output translator delegate methods
    
    def build_started(params)
      @build_metadata = params
    end

    def build_action(params)
      @build_actions_completed << params
    end

    def build_error_detected(params)
    end

    def build_succeeded
      @build_successful = true
    end

    def build_failed
    end

    def build_action_failed(params)
    end
  end
end
