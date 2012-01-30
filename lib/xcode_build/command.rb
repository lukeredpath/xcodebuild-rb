require 'state_machine'

require_relative "command_action"

module XcodeBuild
  class Command
    attr_reader :actions_completed
    attr_writer :finished_at

    def initialize(metadata)
      @actions_completed = []
      @metadata = metadata
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

      after_transition :running => [:successful, :failed] do |build|
        build.finished_at = Time.now
      end
    end

    def add_action(params)
      @actions_completed << CommandAction.new(params)
    end

    def failed_actions
      @actions_completed.select { |a| a.failed? }
    end

    def action_with_params(params)
      @actions_completed.detect { |a| a == CommandAction.new(params) }
    end

    def last_action
      @actions_completed.last
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