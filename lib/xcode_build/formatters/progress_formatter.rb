# encoding: UTF-8
require_relative '../utilities/colorize'

module XcodeBuild
  module Formatters
    class ProgressFormatter
      include XcodeBuild::Utilities::Colorize
      
      def initialize(output = STDOUT)
        @output = output
      end
      
      def build_started(build)
        puts bold("Building target: #{build.target} (in #{build.project_name}.xcproject)")
        puts
        puts "Configuration: #{build.configuration}"
      end
      
      def build_action_finished(action)
        if action.has_errors?
          print red("F")
        else
          print green(".")
        end
      end
      
      def build_finished(build)
        puts
        puts
        puts "Finished in #{build.duration} seconds."
        
        if build.successful?
          puts green("Build succeeded.")
        else
          puts red("Build failed.")
          puts
          puts "Failed build actions:"
          puts
          error_counter = 1
          build.actions_completed.each do |action|
            next unless action.has_errors?
            
            puts indent("#{error_counter}) #{action.type} #{action.arguments.join(" ")}")
            puts

            action.errors.each do |err|
              puts indent("   #{red(err.message)}")
              puts indent(cyan("   in #{err.file}:#{err.line.to_s}"))
              puts
            end
            
            error_counter += 1
          end
        end
      end
      
      private
      
      def puts(str = "")
        @output.puts(str)
      end
      
      def color_enabled?
        true
      end
      
      def indent(string)
        "  #{string}"
      end
    end
  end
end
