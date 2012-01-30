# encoding: UTF-8
require_relative '../utilities/colorize'

module XcodeBuild
  module Formatters
    class ProgressFormatter
      include XcodeBuild::Utilities::Colorize
      
      def initialize(output = STDOUT)
        @output = output
      end
      
      def clean_started(clean)
        report_started("Cleaning", clean)
      end
      
      def clean_action_finished(action)
        report_action_finished(action)
      end
      
      def clean_finished(clean)
        report_finished("Clean", clean)
      end
      
      def build_started(build)
        report_started("Building", build)
      end
      
      def build_action_finished(action)
        report_action_finished(action)
      end
      
      def build_finished(build)
        report_finished("Build", build)
      end
      
      def report_finished(type, object)
        puts
        puts
        puts "Finished in #{object.duration} seconds."
        
        if object.successful?
          puts green("#{type} succeeded.")
        else
          puts red("#{type} failed.")
          puts
          puts "Failed #{type.downcase} actions:"
          puts
          error_counter = 1
          object.actions_completed.each do |action|
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
        puts
      end
      
      private
      
      def puts(str = "")
        @output.puts( str)
      end
      
      def color_enabled?
        true
      end
      
      def indent(string)
        "  #{string}"
      end
      
      def report_started(type, object)
        puts
        banner = "#{type} target: #{object.target} (in #{object.project_name}.xcproject)"
        puts bold(banner)
        puts banner.length.times.map { "=" }.join
        puts
        puts "Configuration: #{object.configuration}"
      end
      
      def report_action_finished(action)
        if action.has_errors?
          print red("F")
        else
          print green(".")
        end
      end
    end
  end
end
