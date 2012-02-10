# encoding: UTF-8
require 'xcode_build/utilities/colorize'

module XcodeBuild
  module Formatters
    class ProgressFormatter
      include XcodeBuild::Utilities::Colorize
      
      def initialize(output = STDOUT)
        @output = output
        @action_count = 0
      end
      
      def build_action_starting(action_type)
        puts cyan("=> Running xcodebuild #{action_type}")
        @action_count = 0
      end
      
      def clean_started(clean)
        report_started("Cleaning", clean)
        @action_count += 1
      end
      
      def clean_step_finished(step)
        report_step_finished(step)
      end
      
      def clean_finished(clean)
        report_finished(clean)
      end
      
      def build_started(build)
        report_started("Building", build)
        @action_count += 1
      end
      
      def build_step_finished(step)
        report_step_finished(step)
      end
      
      def build_finished(build)
        report_finished(build)
      end
      
      def warning_detected
        print yellow("x")
      end
      
      def report_finished(object)
        puts
        report_warnings(object)
        puts
        puts "Finished in #{object.duration} seconds."
        
        if object.successful?
          puts green("#{object.label} succeeded.")
        else
          puts red("#{object.label} failed.")
          puts
          puts "Failed #{object.label.downcase} steps:"
          puts
          error_counter = 1
          object.steps_completed.each do |step|
            next unless step.has_errors?

            puts indent("#{error_counter}) #{step.type} #{step.arguments.join(" ")}")

            step.errors.each do |err|
              puts indent(indent(red(err.message.capitalize)))
              if err.error_detail
                puts indent(indent(cyan(err.error_detail))) 
              else
                puts
              end
              puts
            end
            
            error_counter += 1
          end
        end
        puts
      end
      
      def report_warnings(object)
        return unless object.respond_to?(:warnings)
        return unless object.warnings.count > 0
        
        puts
        puts "The following warnings were reported:"
        puts
        
        object.warnings.each_with_index do |warning, index|
          puts indent(yellow("#{index+1}) #{warning.message}"))
          puts indent(cyan(warning.warning_detail))
          puts
        end
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
        puts unless @action_count.zero?
        puts
        banner = "#{type} target: #{object.target} (in #{object.project_name}.xcproject)"
        puts bold(banner)
        puts banner.length.times.map { "=" }.join
        puts
        puts "Configuration: #{object.configuration}"
      end
      
      def report_step_finished(step)
        if step.has_errors?
          print red("F")
        else
          print green(".")
        end
      end
    end
  end
end
