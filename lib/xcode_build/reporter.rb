require "xcode_build/reporting/build_reporting"
require "xcode_build/reporting/clean_reporting"

module XcodeBuild
  class Reporter
    include Reporting::BuildReporting
    include Reporting::CleanReporting
    
    attr_accessor :delegate

    def initialize(delegate = nil)
      @delegate = delegate
    end
    
    def direct_raw_output_to=(stream)
      @output_stream = stream
    end
    
    def beginning_translation_of_line(line)
      (@output_stream << line) if @output_stream
    end
    
    def report_running_action(action)
      notify :build_action_starting, action
    end

    private

    def notify(event, *args)
      return unless @delegate
      @delegate.send(event, *args) if @delegate.respond_to?(event)
    end
  end
end
