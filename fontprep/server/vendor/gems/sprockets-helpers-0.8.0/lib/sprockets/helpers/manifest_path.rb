module Sprockets
  module Helpers
    # `ManifestPath` uses the digest path and
    # prepends the prefix.
    class ManifestPath < AssetPath
      def initialize(uri, path, options = {})
        @uri     = uri
        @options = {
          :body   => false,
          :prefix => Helpers.prefix
        }.merge options
        
        @uri.path = path.to_s
      end
    end
  end
end
