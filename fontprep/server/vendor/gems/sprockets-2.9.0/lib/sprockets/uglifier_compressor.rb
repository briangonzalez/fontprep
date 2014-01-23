require 'tilt'

module Sprockets
  class UglifierCompressor < Tilt::Template
    self.default_mime_type = 'application/javascript'

    def self.engine_initialized?
      defined?(::Uglifier)
    end

    def initialize_engine
      require_template_library 'uglifier'
    end

    def prepare
    end

    def evaluate(context, locals, &block)
      Uglifier.new(:copyright => false).compile(data)
    end
  end
end
