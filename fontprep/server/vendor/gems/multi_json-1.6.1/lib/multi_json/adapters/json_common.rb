module MultiJson
  module Adapters
    module JsonCommon
      def load(string, options={})
        string = string.read if string.respond_to?(:read)
        ::JSON.parse("[#{string}]", process_load_options!(options)).first
      end

      def dump(object, options={})
        object.to_json(process_dump_options!(options))
      end

    protected

      def process_load_options!(options={})
        process_options!({:create_additions => false}, options) do |opts|
          opts.merge!(:symbolize_names => true) if options.delete(:symbolize_keys)
        end
      end

      def process_dump_options!(options={})
        process_options!({}, options) do |opts|
          opts.merge!(::JSON::PRETTY_STATE_PROTOTYPE.to_h) if options.delete(:pretty)
        end
      end

      def process_options!(default_options, options)
        return default_options if options.empty?
        yield default_options
        default_options.merge!(options)
      end

    end
  end
end
