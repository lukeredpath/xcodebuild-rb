require 'stringio'

module XcodeBuild
  COMMAND_LINE_SETTINGS_KEY = "<command-line>"
  
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

  def self.build_settings(args = "", runner = XcodeBuild)
    output = StringIO.new.tap do |io|
      runner.run("#{args} -showBuildSettings", io)
      io.rewind
    end

    settings = {}
    current_settings = nil

    pairs = output.readlines.each do |line|
      if line =~ /Build settings for action \w+ and target (\w+)/
        current_settings = settings[$1] = []
      elsif line =~ /from command line/
        current_settings = settings[COMMAND_LINE_SETTINGS_KEY] = []
      else
        current_settings << line.scan(/\s+(\w+)\s=\s(.*)/)
      end
    end
    
    settings.each { |target, target_settings| settings[target] = Hash[*target_settings.flatten] }
    settings
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
