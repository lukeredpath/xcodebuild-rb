# encoding: UTF-8
require 'xcode_build/utilities/colorize'

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
      
      def clean_step_finished(step)
        report_step_finished(step)
      end
      
      def clean_finished(clean)
        report_finished("Clean", clean)
      end
      
      def build_started(build)
        report_started("Building", build)
      end
      
      def build_step_finished(step)
        report_step_finished(step)
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
          puts "Failed #{type.downcase} steps:"
          puts
          error_counter = 1
          object.steps_completed.each do |step|
            next unless step.has_errors?

            puts indent("#{error_counter}) #{step.type} #{step.arguments.join(" ")}")

            step.errors.each do |err|
              print indent("   #{red(err.message)}")
              if err.error_detail
                puts indent(cyan(err.error_detail)) 
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
