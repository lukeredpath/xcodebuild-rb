# encoding: UTF-8
require_relative 'translations'

module XcodeBuild
  class OutputTranslator
    def initialize(delegate)
      @delegate = delegate
      @translator_modules = []
      @translators = []
      OutputTranslator.prepare_instance(self)
    end
    
    def <<(line)
      notify_delegate(:beginning_translation_of_line, args: line)
      @translators.each { |t| t.attempt_translation(line) }
    end
    
    def use_translator(translator_module)
      unless translator_module.nil? || @translator_modules.include?(translator_module)
        @translator_modules << translator_module
        @translators << ConcreteTranslator.new(@delegate).extend(translator_module)
      end
    end
    
    class << self
      def use_translator(translator_module_or_key)
        if translator_module_or_key.is_a?(Symbol)
          translator_module = Translations.registered_translator(translator_module_or_key)
        else
          translator_module = translator_module_or_key
        end
        
        @any_instance_translators ||= []
        @any_instance_translators << translator_module
      end
      
      def prepare_instance(output_translator)
        @any_instance_translators.each do |translator|
          output_translator.use_translator(translator)
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
    
    module TranslatorHelpers
      def notify_delegate(message, options = {args: []})
        if @delegate.respond_to?(message)
          @delegate.send(message, *options[:args])
        else
          if options[:required]
            raise MissingDelegateMethodError.new(message)
          end
        end
      end
    end
    
    class ConcreteTranslator
      include TranslatorHelpers
      
      def initialize(delegate)
        @delegate = delegate
      end
    end
    
    include TranslatorHelpers
  end
end

XcodeBuild::OutputTranslator.use_translator(:building)
