module XcodeBuild
  module Translations
    module Building
      def attempt_to_translate(line)
        if line =~ /^\=\=\= BUILD/
          notify_build_started(line)
        end
        
        return unless building?
        
        if line =~ /^\*\* BUILD (\w+) \*\*/
          notify_build_ended($1)
          return
        end

        if @beginning_build_step
          @beginning_build_step = false
          notify_build_step(line) unless line.strip.empty?
          return
        end

        if @beginning_error_report
          if line =~ /^\(\d+ failure(s?)\)/
            @beginning_error_report = false
          else
            notify_build_step_failed(line)
          end
        end

        case line
        when /^(.*):(\d+):(\d+): error: (.*)$/
          notify_build_error($1, $2, $3, $4)
        when /^\s+setenv (\w+) (.*)/
          notify_env_var($1, $2)
        when /^The following build commands failed:/
          @beginning_error_report = true
        when /^\n/
          @beginning_build_step = true
        end
      end
      
      def building?
        @building
      end

      private

      def notify_build_started(line)
        @building = true
        
        target = line.match(/TARGET (\w+)/)[1]
        project = line.match(/PROJECT (\w+)/)[1]

        if line =~ /DEFAULT CONFIGURATION \((\w+)\)/
          configuration = $1
          default = true
        else
          configuration = line.match(/CONFIGURATION (\w+)/)[1]
          default = false
        end

        notify_delegate(:build_started, :required => true, :args => [{
                 :target => target,
                :project => project,
          :configuration => configuration,
                :default => default
        }])
      end

      def notify_build_step(line)
        notify_delegate(:build_step, :args => [build_step_from_line(line)])
      end

      def notify_build_error(file, line, char, message)
        notify_delegate(:build_error_detected, :args => [{
             :file => file,
             :line => line.to_i,
             :char => char.to_i,
          :message => message
        }])
      end

      def notify_build_ended(result)
        if result =~ /SUCCEEDED/
          notify_delegate(:build_succeeded, :required => true)
        else
          notify_delegate(:build_failed, :required => true)
        end
      end

      def notify_build_step_failed(line)
        notify_delegate(:build_step_failed, :args => [build_step_from_line(line)])
      end
      
      def notify_env_var(key, value)
        notify_delegate(:build_env_variable_detected, :args => [key, value])
      end

      def build_step_from_line(line)
        parts = line.strip.split(" ")
        {:type => parts.shift, :arguments => parts}
      end
    end

    register_translation :building, Building
  end
end
