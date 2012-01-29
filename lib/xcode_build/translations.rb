module XcodeBuild
  module Translations
    extend self
    
    def registered_translations
      @registered_translators ||= {}
    end
    
    def register_translation(key, the_module)
      registered_translations[key] = the_module
    end
    
    def registered_translation(key)
      registered_translations[key]
    end
  end
end

require_relative "translations/building"

