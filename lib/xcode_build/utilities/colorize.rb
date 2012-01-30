module XcodeBuild
  module Utilities
    module Colorize # borrowed from rspec-core
      def color(text, color_code)
        color_enabled? ? "#{color_code}#{text}\e[0m" : text
      end

      def bold(text)
        color(text, "\e[1m")
      end

      def red(text)
        color(text, "\e[31m")
      end

      def green(text)
        color(text, "\e[32m")
      end

      def yellow(text)
        color(text, "\e[33m")
      end

      def blue(text)
        color(text, "\e[34m")
      end

      def magenta(text)
        color(text, "\e[35m")
      end

      def cyan(text)
        color(text, "\e[36m")
      end

      def white(text)
        color(text, "\e[37m")
      end

      def short_padding
        '  '
      end
    end
  end
end
