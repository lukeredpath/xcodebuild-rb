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
    
    $?.exitstatus
  end

	def self.build_settings(opts = nil)
		opts ||= ""
		output = StringIO.new
		run(opts + ' -showBuildSettings', output)
		Hash[ output.string.scan(/^\s+(\w+)\s+=\s+(.+)$/) ]
	end
end

require 'xcode_build/build_action'
require 'xcode_build/build_step'
require 'xcode_build/output_translator'
require 'xcode_build/reporter'
require 'xcode_build/formatters'
require 'xcode_build/tasks'

# configure the default translations for general use
XcodeBuild::OutputTranslator.use_translation(:building)
XcodeBuild::OutputTranslator.use_translation(:cleaning)
