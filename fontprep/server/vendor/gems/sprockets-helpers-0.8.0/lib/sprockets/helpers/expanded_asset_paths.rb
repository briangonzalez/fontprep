module Sprockets
  module Helpers
    class ExpandedAssetPaths
      def initialize(uri, asset, options = {})
        @uri = uri
        @asset = asset
        @options = { :body => true }.merge options
      end

      def to_a
        @asset.to_a.map do |dependency|
          AssetPath.new(@uri.clone, dependency, @options).to_s
        end
      end
    end
  end
end
