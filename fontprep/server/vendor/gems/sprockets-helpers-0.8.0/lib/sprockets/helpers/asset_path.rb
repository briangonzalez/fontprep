module Sprockets
  module Helpers
    # `AssetPath` generates a full path for an asset
    # that exists in Sprockets environment.
    class AssetPath < BasePath
      def initialize(uri, asset, options = {})
        @uri     = uri
        @options = {
          :body   => false,
          :digest => Helpers.digest,
          :prefix => Helpers.prefix
        }.merge options
        
        @uri.path = @options[:digest] ? asset.digest_path : asset.logical_path
      end
      
      protected
      
      def rewrite_path
        prefix = if options[:prefix].respond_to? :call
          warn 'DEPRECATION WARNING: Using a Proc for Sprockets::Helpers.prefix is deprecated and will be removed in 1.0. Please use Sprockets::Helpers.asset_host instead.'
          options[:prefix].call uri.path
        else
          options[:prefix].to_s
        end
        
        prepend_path(prefix)
      end
      
      def rewrite_query
        append_query('body=1') if options[:body]
      end
    end
  end
end
