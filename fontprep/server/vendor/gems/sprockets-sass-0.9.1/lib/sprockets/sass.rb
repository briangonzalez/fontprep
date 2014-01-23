require 'sprockets'
require 'sprockets/sass/version'
require 'sprockets/sass/sass_template'
require 'sprockets/sass/scss_template'
require 'sprockets/engines'

module Sprockets
  module Sass
    autoload :CacheStore, 'sprockets/sass/cache_store'
    autoload :Compressor, 'sprockets/sass/compressor'
    autoload :Importer,   'sprockets/sass/importer'
    
    class << self
      # Global configuration for `Sass::Engine` instances.
      attr_accessor :options
      
      # When false, the asset path helpers provided by
      # sprockets-helpers will not be added as Sass functions.
      # `true` by default.
      attr_accessor :add_sass_functions
    end
    
    @options = {}
    @add_sass_functions = true
  end
  
  register_engine '.sass', Sass::SassTemplate
  register_engine '.scss', Sass::ScssTemplate
end
