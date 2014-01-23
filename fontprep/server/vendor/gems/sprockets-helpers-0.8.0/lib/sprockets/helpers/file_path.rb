module Sprockets
  module Helpers
    # `FilePath` generates a full path for a regular file
    # in the output path. It's used by #asset_path to generate
    # paths when using asset tags like #javascript_include_tag,
    # #stylesheet_link_tag, and #image_tag
    class FilePath < BasePath
      
      protected
      
      # Hook for rewriting the base path.
      def rewrite_path # :nodoc:
        if uri.path[0] != ?/
          prepend_path File.join('/', options[:dir].to_s)
        end
      end
      
      # Hook for rewriting the query string.
      def rewrite_query # :nodoc:
        if timestamp = compute_mtime
          append_query(timestamp.to_i.to_s)
        end
      end
      
      # Returns the mtime for the given path (relative to
      # the output path). Returns nil if the file doesn't exist.
      def compute_mtime # :nodoc:
        public_path = File.join(Helpers.public_path, uri.path)
        
        if File.exist?(public_path)
          File.mtime(public_path)
        else
          nil
        end
      end
    end
  end
end
