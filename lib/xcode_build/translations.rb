module XcodeBuild
  module Translations
    extend self
    
    def registered_translators
      @registered_translators ||= {}
    end
    
    def register_translator(key, the_module)
      registered_translators[key] = the_module
    end
    
    def registered_translator(key)
      registered_translators[key]
    end
  end
end

require_relative "translations/building"

