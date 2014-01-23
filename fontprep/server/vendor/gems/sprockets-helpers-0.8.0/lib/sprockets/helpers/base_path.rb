require 'uri'
require 'zlib'

module Sprockets
  module Helpers
    #
    class BasePath
      # The parsed URI from which to generate the full path to the asset.
      attr_reader :uri

      # The various options used when generating the path.
      attr_reader :options

      #
      def initialize(uri, options = {})
        @uri     = uri
        @options = options
      end

      # Returns the full path to the asset, complete with
      # timestamp.
      def to_s
        rewrite_path
        rewrite_query
        rewrite_host

        uri.to_s
      end

      protected

      # Hook for rewriting the base path.
      def rewrite_path # :nodoc:
      end

      # Hook for rewriting the query string.
      def rewrite_query # :nodoc:
      end

      # Hook for rewriting the host.
      def rewrite_host # :nodoc:
        if host = compute_asset_host
          uri.host   = host
          uri.scheme = compute_scheme
        end
      end

      # Pick an asset host for this source. Returns +nil+ if no host is set,
      # the host if no wildcard is set, the host interpolated with the
      # numbers 0-3 if it contains <tt>%d</tt> (the number is the source hash mod 4),
      # or the value returned from invoking call on an object responding to call
      # (proc or otherwise).
      def compute_asset_host # :nodoc:
        return nil if options[:asset_host] == false

        if host = options[:asset_host] || Helpers.asset_host
          if host.respond_to?(:call)
            host.call(uri.to_s)
          elsif host =~ /%d/
            host % (Zlib.crc32(uri.to_s) % 4)
          elsif host.empty?
            nil
          else
            host
          end
        end
      end

      # Pick a scheme for the protocol if we are using
      # an asset host.
      def compute_scheme # :nodoc:
        protocol = options[:protocol] || Helpers.protocol

        if protocol.nil? || protocol == :relative
          nil
        else
          protocol.to_s.sub %r{://\z}, ''
        end
      end

      # Prepends the given path. If the path is absolute
      # An attempt to merge the URIs is made.
      #
      # TODO: Simplify this once Proc support for :prefix is removed.
      def prepend_path(value) # :nodoc:
        prefix_uri = URI.parse(value)
        uri.path   = File.join prefix_uri.path, uri.path

        if prefix_uri.absolute?
          @uri = prefix_uri.merge(uri)
        end
      end

      # Append the given query string to the URI
      # instead of clobbering it.
      def append_query(value) # :nodoc:
        if uri.query.nil? || uri.query.empty?
          uri.query = value
        else
          uri.query << ('&' + value)
        end
      end
    end
  end
end
