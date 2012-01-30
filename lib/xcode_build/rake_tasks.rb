require 'rake/tasklib'

module XcodeBuild
  class Tasks < ::Rake::TaskLib
    def initialize(namespace = :xcode, &block)
      @configuration = Configuration.new
      @namespace = namespace
      yield @configuration if block_given?
      define
    end

    class Configuration < OpenStruct
    end
    
    private
    
    def define
      namespace(@namespace) do
      end
    end
  end
end
