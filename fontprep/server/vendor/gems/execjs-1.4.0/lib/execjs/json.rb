require "multi_json"

module ExecJS
  module JSON
    if MultiJson.respond_to?(:dump)
      def self.decode(obj)
        MultiJson.load(obj)
      end

      def self.encode(obj)
        MultiJson.dump(obj)
      end
    else
      def self.decode(obj)
        MultiJson.decode(obj)
      end

      def self.encode(obj)
        MultiJson.encode(obj)
      end
    end
  end
end
