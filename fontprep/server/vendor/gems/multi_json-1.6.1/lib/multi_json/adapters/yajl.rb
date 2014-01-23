require 'yajl' unless defined?(::Yajl)

module MultiJson
  module Adapters
    # Use the Yajl-Ruby library to dump/load.
    module Yajl
      extend self

      ParseError = ::Yajl::ParseError

      def load(string, options={}) #:nodoc:
        ::Yajl::Parser.new(:symbolize_keys => options[:symbolize_keys]).parse(string)
      end

      def dump(object, options={}) #:nodoc:
        ::Yajl::Encoder.encode(object, options)
      end
    end
  end
end
