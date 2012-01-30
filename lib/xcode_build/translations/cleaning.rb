module XcodeBuild
  module Translations
    module Cleaning
      def attempt_to_translate(line)
        if line =~ /^\=\=\= CLEAN/
          notify_clean_started(line)
        end
        
        return unless cleaning?
        
        if line =~ /^\*\* CLEAN (\w+) \*\*/
          notify_clean_ended($1)
          return
        end
        
        if @beginning_clean_step
          @beginning_clean_step = false
          notify_clean_step(line) unless line.strip.empty?
          return
        end
        
        if @beginning_error_report
          if line =~ /^\(\d+ failure(s?)\)/
            @beginning_error_report = false
          else
            notify_clean_step_failed(line)
          end
        end
        
        case line
        when /^error: (.*)$/
          notify_clean_error($1)
        when /^The following build commands failed:/
          @beginning_error_report = true
        when /^\n/
          @beginning_clean_step = true
        end
      end

      private
      
      def cleaning?
        @cleaning
      end
      
      def notify_clean_started(line)
        @cleaning = true
        
        target = line.match(/TARGET (\w+)/)[1]
        project = line.match(/PROJECT (\w+)/)[1]

        if line =~ /DEFAULT CONFIGURATION \((\w+)\)/
          configuration = $1
          default = true
        else
          configuration = line.match(/CONFIGURATION (\w+)/)[1]
          default = false
        end

        notify_delegate(:clean_started, required: true, args: [{
                 target: target,
                project: project,
          configuration: configuration,
                default: default
        }])
      end
      
      def notify_clean_step(line)
        notify_delegate(:clean_step, args: [clean_step_from_line(line)])
      end
      
      def notify_clean_step_failed(line)
        notify_delegate(:clean_step_failed, args: [clean_step_from_line(line)])
      end
      
      def notify_clean_error(message)
        notify_delegate(:clean_error_detected, args: [{message: message}])
      end
      
      def notify_clean_ended(result)
        if result =~ /SUCCEEDED/
          notify_delegate(:clean_succeeded, required: true)
        end
      end
      
      def clean_step_from_line(line)
        parts = line.strip.split(" ")
        {type: parts.shift, arguments: parts}
      end
    end

    register_translation :cleaning, Cleaning
  end
end
