# encoding: UTF-8

module XcodeBuild
  class OutputTranslator
    def initialize(delegate)
      @delegate = delegate
    end
    
    def <<(line)
      if line =~ /^\*\* BUILD (\w+) \*\*/
        notify_build_ended($1)
        return
      end
      
      if @beginning_build_action
        @beginning_build_action = false
        notify_build_action(line) unless line.strip.empty?
        return
      end
      
      case line
      when /^\=\=\= BUILD/
        notify_build_started(line)
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
      
      @delegate.build_started(
               target: target,
              project: project,
        configuration: configuration,
              default: default
      )
    end
    
    def notify_build_action(line)
      parts = line.split(" ")

      @delegate.build_action(type: parts.shift, arguments: parts)
    end
    
    def notify_build_ended(result)
      if result =~ /SUCCEEDED/
        @delegate.build_succeeded
      else
        @delegate.build_failed
      end
    end
  end
end
