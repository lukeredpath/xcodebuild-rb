module XcodeBuild
  def self.run(args = "", output_buffer = STDOUT)
    IO.popen("xcodebuild #{args}", err: [:child, :out]) do |io|
      begin
        while line = io.readline
          output_buffer << line
        end
      rescue EOFError
      end
    end
  end
end

require_relative 'xcode_build/output_translator'
