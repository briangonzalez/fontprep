require 'oj' unless defined?(::Oj)

module MultiJson
  module Adapters
    # Use the Oj library to dump/load.
    module Oj
      extend self

      DEFAULT_OPTIONS = {:mode => :compat, :time_format => :ruby}.freeze

      ParseError = if defined?(::Oj::ParseError)
        ::Oj::ParseError
      else
        SyntaxError
      end

      def load(string, options={}) #:nodoc:
        options.merge!(:symbol_keys => options[:symbolize_keys])
        options[:mode] = :strict
        ::Oj.load(string, DEFAULT_OPTIONS.merge(options))
      end

      def dump(object, options={}) #:nodoc:
        options.merge!(:indent => 2) if options[:pretty]
        ::Oj.dump(object, DEFAULT_OPTIONS.merge(options))
      end
    end
  end
end
