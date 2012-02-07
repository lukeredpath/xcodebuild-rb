require 'rake/tasklib'

module XcodeBuild
  module Tasks
    class BuildTask < ::Rake::TaskLib
      include Rake::DSL if defined?(Rake::DSL)

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
      attr_accessor :reporter_klass

      def initialize(namespace = :xcode, &block)
        @namespace = namespace
        @output_to = STDOUT
        @invoke_from_within = "."
        @reporter_klass = XcodeBuild::Reporter
        @hooks = {}
        
        yield self if block_given?
        define
      end
      
      def after_build(&block)
        @hooks[:after_build] = block
      end
      
      def after_clean(&block)
        @hooks[:after_clean] = block
      end
      
      def after_archive(&block)
        @hooks[:after_archive] = block
      end
      
      def execute_hook(name, *args)
        if hook = @hooks[name.to_sym]
          hook.call(*args)
        end
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
      
      def reporter
        @reporter ||= @reporter_klass.new(formatter)
      end

      private
      
      def output_buffer
        @output_buffer ||= XcodeBuild::OutputTranslator.new(reporter)
      end
      
      def build_opts_string(*additional_opts)
        (build_opts + additional_opts).compact.join(" ")
      end

      def xcodebuild(action)
        reporter.direct_raw_output_to = output_to unless formatter
        
        reporter.report_running_action(action) if reporter.respond_to?(:report_running_action)
        
        status = Dir.chdir(invoke_from_within) do
          XcodeBuild.run(build_opts_string(action), output_buffer)
        end
        
        check_status(status)
        
        if reporter.build && reporter.build.failed?
          # sometimes, a build/archive can fail and xcodebuild won't return a non-zero code
          raise "xcodebuild failed (#{reporter.build.failed_steps.length} steps failed)"
        end
        
        case action
        when :build
          execute_hook(:after_build, reporter.build)
        when :archive
          execute_hook(:after_build, reporter.build)
          execute_hook(:after_archive, reporter.build)
        when :clean
          execute_hook(:after_clean, reporter.clean)
        end
      end

      def define
        namespace(@namespace) do
          desc "Creates an archive build of the specified target(s)."
          task :archive do
            raise "You need to specify a `scheme' in order to be able to create an archive build!" unless scheme
            xcodebuild :archive
          end

          desc "Builds the specified target(s)."
          task :build do
            xcodebuild :build
          end
          
          desc "Cleans the build using the same build settings."
          task :clean do
            xcodebuild :clean
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
