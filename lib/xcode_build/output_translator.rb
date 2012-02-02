# encoding: UTF-8
require 'xcode_build/translations'

module XcodeBuild
  class OutputTranslator
    attr_reader :translations, :delegate
    
    def initialize(delegate, options = {})
      @delegate = delegate
      @translation_modules = []
      @translations = []
      OutputTranslator.prepare_instance(self) unless options[:ignore_global_translations]
    end
    
    def <<(line)
      notify_delegate(:beginning_translation_of_line, :args => line)
      translations.each { |translation| translation.attempt_to_translate(line) }
    end
    
    def use_translation(translation_module)
      unless translation_module.nil? || @translation_modules.include?(translation_module)
        @translation_modules << translation_module
        @translations << ConcreteTranslation.new(@delegate, translation_module)
      end
    end
    
    class << self
      def use_translation(translation_module_or_key)
        if translation_module_or_key.is_a?(Symbol)
          translation_module = Translations.registered_translation(translation_module_or_key)
        else
          translation_module = translation_module_or_key
        end
        
        @any_instance_translations ||= []
        @any_instance_translations << translation_module
      end
      
      def prepare_instance(translator)
        @any_instance_translations.each do |translation|
          translator.use_translation(translation)
        end
      end
    end
    
    class MissingDelegateMethodError < StandardError
      def initialize(method)
        @method = method
      end
      
      def message
        "Delegate must implement the #{@method.to_sym} method."
      end
    end
    
    private
    
    module TranslationHelpers
      def notify_delegate(message, options = {})
        options[:args] ||= []
        if @delegate.respond_to?(message)
          @delegate.send(message, *options[:args])
        else
          if options[:required]
            raise MissingDelegateMethodError.new(message)
          end
        end
      end
    end
    
    class ConcreteTranslation
      include TranslationHelpers
      
      def initialize(delegate, translation)
        @delegate = delegate
        extend translation
      end
    end
    
    include TranslationHelpers
  end
end

