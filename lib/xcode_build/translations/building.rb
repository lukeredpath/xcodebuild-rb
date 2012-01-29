module XcodeBuild
  module Translations
    module Building
      def attempt_translation(line)
        if line =~ /^\*\* BUILD (\w+) \*\*/
          notify_build_ended($1)
          return
        end

        if @beginning_build_action
          @beginning_build_action = false
          notify_build_action(line) unless line.strip.empty?
          return
        end

        if @beginning_error_report
          notify_build_action_failed(line)
        end

        case line
        when /^\=\=\= BUILD/
          notify_build_started(line)
        when /^The following build commands failed:/
          @beginning_error_report = true
        when /^\n/
          @beginning_build_action = true
        end
      end
      
      private
      
      def notify_build_started(line)
        target = line.match(/TARGET (\w+)/)[1]
        project = line.match(/PROJECT (\w+)/)[1]

        if line =~ /DEFAULT CONFIGURATION \((\w+)\)/
          configuration = $1
          default = true
        else
          configuration = line.match(/CONFIGURATION (\w+)/)[1]
          default = false
        end

        notify_delegate(:build_started, required: true, args: [{
                 target: target,
                project: project,
          configuration: configuration,
                default: default
        }])
      end

      def notify_build_action(line)
        notify_delegate(:build_action, args: [build_action_from_line(line)])
      end

      def notify_build_ended(result)
        if result =~ /SUCCEEDED/
          notify_delegate(:build_succeeded, required: true)
        else
          notify_delegate(:build_failed, required: true)
        end
      end

      def notify_build_action_failed(line)
        notify_delegate(:build_action_failed, args: [build_action_from_line(line)])
      end

      def build_action_from_line(line)
        parts = line.split(" ")
        {type: parts.shift, arguments: parts}
      end
    end
    
    register_translator :building, Building
  end
end
