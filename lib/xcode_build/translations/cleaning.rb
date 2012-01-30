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
        
        if @beginning_clean_action
          @beginning_clean_action = false
          notify_clean_action(line) unless line.strip.empty?
          return
        end
        
        case line
        when /^\n/
          @beginning_clean_action = true
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
      
      def notify_clean_action(line)
        notify_delegate(:clean_action, args: [clean_action_from_line(line)])
      end
      
      def notify_clean_ended(result)
        if result =~ /SUCCEEDED/
          notify_delegate(:clean_succeeded, required: true)
        end
      end
      
      def clean_action_from_line(line)
        parts = line.strip.split(" ")
        {type: parts.shift, arguments: parts}
      end
    end

    register_translation :cleaning, Cleaning
  end
end
