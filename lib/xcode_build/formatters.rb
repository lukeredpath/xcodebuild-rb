require "xcode_build/formatters/progress_formatter"

module XcodeBuild
  module Formatters
    BUILT_IN_TYPES = {
      progress: XcodeBuild::Formatters::ProgressFormatter
    }
    
    def self.[](type)
      if klass = BUILT_IN_TYPES[type]
        klass.new
      else
        raise "Unknown formatter type: #{type}!"
      end
    end
  end
end
