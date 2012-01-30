module XcodeBuild
  def self.run(args = "", output_buffer = STDOUT)
    IO.popen("xcodebuild #{args} 2>&1") do |io|
      begin
        while line = io.readline
          begin
            output_buffer << line
          rescue StandardError => e
            puts "Error from output buffer: #{e.inspect}"
            puts e.backtrace
          end
        end
      rescue EOFError
      end
    end
  end
end

require_relative "xcode_build/command"
require_relative "xcode_build/command_action"
require_relative 'xcode_build/output_translator'
require_relative 'xcode_build/reporter'
require_relative 'xcode_build/formatters'

# configure the default translations for general use
XcodeBuild::OutputTranslator.use_translation(:building)
XcodeBuild::OutputTranslator.use_translation(:cleaning)
