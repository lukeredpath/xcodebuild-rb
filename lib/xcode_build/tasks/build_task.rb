require 'rake/tasklib'

module XcodeBuild
  module Tasks
    class BuildTask < ::Rake::TaskLib
      attr_accessor :project_name
      attr_accessor :target
      attr_accessor :workspace
      attr_accessor :scheme
      attr_accessor :configuration
      attr_accessor :arch
      attr_accessor :sdk
      attr_accessor :xcconfig
      attr_accessor :output_to
      attr_accessor :formatter
      attr_accessor :invoke_from_within
      attr_accessor :reporter

      def initialize(namespace = :xcode, &block)
        @namespace = namespace
        @output_to = STDOUT
        @invoke_from_within = "."
        
        yield self if block_given?
        define
      end

      def run(task)
        Rake::Task["#{@namespace}:#{task}"].invoke
      end

      def build_opts
        [].tap do |opts|
          opts << "-project #{project_name}" if project_name
          opts << "-target #{target}" if target
          opts << "-workspace #{workspace}" if workspace
          opts << "-scheme #{scheme}" if scheme
          opts << "-configuration #{configuration}" if configuration
          opts << "-arch #{arch}" if arch
          opts << "-sdk #{sdk}" if sdk
          opts << "-xcconfig #{xcconfig}" if xcconfig
        end
      end

      private
      
      def output_buffer
        if reporter
          XcodeBuild::OutputTranslator.new(reporter)
        elsif formatter
          default_reporter = XcodeBuild::Reporter.new(formatter)
          XcodeBuild::OutputTranslator.new(default_reporter)
        else
          output_to
        end
      end
      
      def build_opts_string(*additional_opts)
        (build_opts + additional_opts).join(" ")
      end

      def define
        namespace(@namespace) do
          desc "Builds the specified target(s)."
          task :build do
            Dir.chdir(invoke_from_within) do
              XcodeBuild.run(build_opts_string, output_buffer)
            end
          end
          
          desc "Cleans the build using the same build settings."
          task :clean do
            Dir.chdir(invoke_from_within) do
              XcodeBuild.run(build_opts_string("clean"), output_buffer)
            end
          end
          
          desc "Builds the specified target(s) from a clean slate."
          task :cleanbuild => [:clean, :build]
        end
      end
    end
  end
end
