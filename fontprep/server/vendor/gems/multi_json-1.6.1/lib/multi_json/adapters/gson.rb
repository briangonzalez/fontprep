require 'gson' unless defined?(::Gson)

module MultiJson
  module Adapters
    # Use the gson.rb library to dump/load.
    module Gson
      extend self

      ParseError = ::Gson::DecodeError

      def load(string, options={}) #:nodoc:
        ::Gson::Decoder.new(options).decode(string)
      end

      def dump(object, options={}) #:nodoc:
        ::Gson::Encoder.new(options).encode(object)
      end
    end
  end
end
