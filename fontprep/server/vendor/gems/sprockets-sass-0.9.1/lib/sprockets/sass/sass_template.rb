require 'tilt'

module Sprockets
  module Sass
    class SassTemplate < Tilt::SassTemplate
      self.default_mime_type = 'text/css'

      # A reference to the current Sprockets context
      attr_reader :context

      # Templates are initialized once the functions are added.
      def self.engine_initialized?
        super && (!Sass.add_sass_functions || defined?(Functions))
      end

      # Add the Sass functions if they haven't already been added.
      def initialize_engine
        super unless self.class.superclass.engine_initialized?

        if Sass.add_sass_functions
          require 'sprockets/sass/functions'
        end
      end

      # Define the expected syntax for the template
      def syntax
        :sass
      end

      # See `Tilt::Template#prepare`.
      def prepare
        @context = nil
        @output  = nil
      end

      # See `Tilt::Template#evaluate`.
      def evaluate(context, locals, &block)
        @output ||= begin
          @context = context
          ::Sass::Engine.new(data, sass_options).render
        rescue ::Sass::SyntaxError => e
          # Annotates exception message with parse line number
          context.__LINE__ = e.sass_backtrace.first[:line]
          raise e
        end
      end

      protected

      # Returns a Sprockets-aware cache store for Sass::Engine.
      def cache_store
        return nil if context.environment.cache.nil?

        if defined?(Sprockets::SassCacheStore)
          Sprockets::SassCacheStore.new context.environment
        else
          CacheStore.new context.environment
        end
      end

      # A reference to the custom Sass importer, `Sprockets::Sass::Importer`.
      def importer
        Importer.new context
      end

      # Assemble the options for the `Sass::Engine`
      def sass_options
        merge_sass_options(default_sass_options, options).merge(
          :filename    => eval_file,
          :line        => line,
          :syntax      => syntax,
          :cache_store => cache_store,
          :importer    => importer,
          :custom      => { :sprockets_context => context }
        )
      end

      # Get the default, global Sass options. Start with Compass's
      # options, if it's available.
      def default_sass_options
        if defined?(Compass)
          merge_sass_options Compass.sass_engine_options.dup, Sprockets::Sass.options
        else
          Sprockets::Sass.options.dup
        end
      end

      # Merges two sets of `Sass::Engine` options, prepending
      # the `:load_paths` instead of clobbering them.
      def merge_sass_options(options, other_options)
        if (load_paths = options[:load_paths]) && (other_paths = other_options[:load_paths])
          other_options[:load_paths] = other_paths + load_paths
        end
        options.merge other_options
      end
    end
  end
end
