require "ostruct"

module XcodeBuild
  class BuildStep
    attr_accessor :failed
    attr_reader :errors

    def initialize(metadata)
      @metadata = metadata
      @errors = []
    end

    def add_error(params)
      @failed = true
      @errors << Error.new(params)
    end

    def has_errors?
      @errors.any?
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

    def failed?
      @failed
    end

    def inspect
      [type, arguments]
    end
    
    private
    
    class Error < OpenStruct
      def error_detail
        if self.file
          "in #{self.file}:#{self.line.to_s}"
        elsif self.command
          "#{self.command} failed with exit code #{self.exit_code}"
        end
      end
    end
  end
end
