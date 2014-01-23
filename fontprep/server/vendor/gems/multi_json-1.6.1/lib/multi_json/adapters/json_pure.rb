require 'json/pure' unless defined?(::JSON)
require 'multi_json/adapters/json_common'

module MultiJson
  module Adapters
    # Use JSON pure to dump/load.
    module JsonPure
      ParseError = ::JSON::ParserError
      extend JsonCommon
    end
  end
end
