require 'state_machine'

require_relative "build_step"

module XcodeBuild
  class BuildAction
    attr_reader :steps_completed
    attr_writer :finished_at

    def initialize(metadata)
      @steps_completed = []
      @metadata = metadata
      @started_at = Time.now
      super()
    end

    state_machine :state, :initial => :running do
      event :success do
        transition :running => :successful
      end

      event :failure do
        transition :running => :failed
      end

      after_transition :running => [:successful, :failed] do |build|
        build.finished_at = Time.now
      end
    end

    def add_step(params)
      @steps_completed << BuildStep.new(params)
    end

    def failed_steps
      @steps_completed.select { |a| a.failed? }
    end

    def step_with_params(params)
      @steps_completed.detect { |a| a == BuildStep.new(params) }
    end

    def last_step
      @steps_completed.last
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
end