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
      
      def reporter
        @reporter ||= XcodeBuild::Reporter.new(formatter).tap do |r|
          r.direct_raw_output_to = output_to unless formatter
        end
      end
      
      def output_buffer
        @output_buffer ||= XcodeBuild::OutputTranslator.new(reporter)
      end
      
      def build_opts_string(*additional_opts)
        (build_opts + additional_opts).join(" ")
      end

      def define
        namespace(@namespace) do
          desc "Builds the specified target(s)."
          task :build do
            status = Dir.chdir(invoke_from_within) do
              XcodeBuild.run(build_opts_string, output_buffer)
            end
            check_status(status)
          end
          
          desc "Cleans the build using the same build settings."
          task :clean do
            status = Dir.chdir(invoke_from_within) do
              XcodeBuild.run(build_opts_string("clean"), output_buffer)
            end
            check_status(status)
          end
          
          desc "Builds the specified target(s) from a clean slate."
          task :cleanbuild => [:clean, :build]
        end
      end
      
      def check_status(status)
        raise "xcodebuild failed (exited with status: #{status})" unless status == 0
      end
    end
  end
end
