require 'sass'

module Sprockets
  module Sass
    class CacheStore < ::Sass::CacheStores::Base
      attr_reader :environment
  
      def initialize(environment)
        @environment = environment
      end
  
      def _store(key, version, sha, contents)
        environment.send :cache_set, "sass/#{key}", { :version => version, :sha => sha, :contents => contents }
      end
  
      def _retrieve(key, version, sha)
        if obj = environment.send(:cache_get, "sass/#{key}")
          return unless obj[:version] == version
          return unless obj[:sha] == sha
          obj[:obj]
        else
          nil
        end
      end
    end
  end
end
