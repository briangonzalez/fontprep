require 'sprockets'
require 'sprockets/helpers/version'
require 'sprockets/helpers/base_path'
require 'sprockets/helpers/asset_path'
require 'sprockets/helpers/expanded_asset_paths'
require 'sprockets/helpers/file_path'
require 'sprockets/helpers/manifest_path'
require 'uri'

module Sprockets
  module Helpers
    class << self
      # Link to assets from a dedicated server.
      attr_accessor :asset_host

      # When true, the asset paths will return digest paths.
      attr_accessor :digest

      # When true, expand assets.
      attr_accessor :expand

      # Set the Sprockets environment to search for assets.
      # This defaults to the context's #environment method.
      attr_accessor :environment

      # The manifest file used for lookup
      attr_accessor :manifest

      # The base URL the Sprocket environment is mapped to.
      # This defaults to '/assets'.
      def prefix
        @prefix ||= '/assets'
      end
      attr_writer :prefix

      # Customize the protocol when using asset hosts.
      # If the value is :relative, A relative protocol ('//')
      # will be used.
      def protocol
        @protocol ||= 'http://'
      end
      attr_writer :protocol

      # The path to the public directory, where the assets
      # not managed by Sprockets will be located.
      # Defaults to './public'
      def public_path
        @public_path ||= './public'
      end
      attr_writer :public_path

      # Convience method for configuring Sprockets::Helpers.
      def configure
        yield self
      end

      # Hack to ensure methods from Sprockets::Helpers override the
      # methods of Sprockets::Context when included.
      def append_features(context) # :nodoc:
        context.class_eval do
          context_methods = context.instance_methods(false)
          Helpers.public_instance_methods.each do |method|
            remove_method(method) if context_methods.include?(method)
          end
        end

        super(context)
      end
    end

    # Returns the path to an asset either in the Sprockets environment
    # or the public directory. External URIs are untouched.
    #
    # ==== Options
    #
    # * <tt>:ext</tt> - The extension to append if the source does not have one.
    # * <tt>:dir</tt> - The directory to prepend if the file is in the public directory.
    # * <tt>:digest</tt> - Wether or not use the digest paths for assets. Set Sprockets::Helpers.digest for global configuration.
    # * <tt>:prefix</tt> - Use a custom prefix for the Sprockets environment. Set Sprockets::Helpers.prefix for global configuration.
    # * <tt>:body</tt> - Adds a ?body=1 flag that tells Sprockets to return only the body of the asset.
    #
    # ==== Examples
    #
    # For files within Sprockets:
    #
    #   asset_path 'xmlhr.js'                       # => '/assets/xmlhr.js'
    #   asset_path 'xmlhr', :ext => 'js'            # => '/assets/xmlhr.js'
    #   asset_path 'xmlhr.js', :digest => true      # => '/assets/xmlhr-27a8f1f96afd8d4c67a59eb9447f45bd.js'
    #   asset_path 'xmlhr.js', :prefix => '/themes' # => '/themes/xmlhr.js'
    #
    # For files outside of Sprockets:
    #
    #   asset_path 'xmlhr'                                # => '/xmlhr'
    #   asset_path 'xmlhr', :ext => 'js'                  # => '/xmlhr.js'
    #   asset_path 'dir/xmlhr.js', :dir => 'javascripts'  # => '/javascripts/dir/xmlhr.js'
    #   asset_path '/dir/xmlhr.js', :dir => 'javascripts' # => '/dir/xmlhr.js'
    #   asset_path 'http://www.example.com/js/xmlhr'      # => 'http://www.example.com/js/xmlhr'
    #   asset_path 'http://www.example.com/js/xmlhr.js'   # => 'http://www.example.com/js/xmlhr.js'
    #
    def asset_path(source, options = {})
      uri = URI.parse(source)

      # Return fast if the URI is absolute
      return source if uri.absolute?

      # When debugging return paths without digests, asset_hosts, etc.
      if options[:debug]
        options[:manifest]   = false
        options[:digest]     = false
        options[:asset_host] = false
      end

      # Append extension if necessary
      source_ext = File.extname(source)
      if options[:ext] && source_ext != ".#{options[:ext]}"
        uri.path << ".#{options[:ext]}"
      end

      # If a manifest is present, try to grab the path from the manifest first
      # Don't try looking in manifest in the first place if we're not looking for digest version
      if options[:manifest] != false && Helpers.manifest && Helpers.manifest.assets[uri.path]
        return Helpers::ManifestPath.new(uri, Helpers.manifest.assets[uri.path], options).to_s
      end

      # If the source points to an asset in the Sprockets
      # environment use AssetPath to generate the full path.
      # With expand, return array of paths of assets required by asset.
      assets_environment.resolve(uri.path) do |path|
        asset = assets_environment[path]
        if options[:expand]
          return Helpers::ExpandedAssetPaths.new(uri, asset, options).to_a
        else
          return Helpers::AssetPath.new(uri, asset, options).to_s
        end
      end

      # Use FilePath for normal files on the file system
      return Helpers::FilePath.new(uri, options).to_s
    end
    alias_method :path_to_asset, :asset_path

    def asset_tag(source, options = {}, &block)
      raise ::ArgumentError, 'block missing' unless block
      path = asset_path source, { :expand => Helpers.expand }.merge(options)
      if options[:expand] && path.kind_of?(Array)
        return path.map(&block).join()
      else
        yield path
      end
    end

    def javascript_tag(source, options = {})
      asset_tag(source, { :ext => 'js' }.merge(options)) do |path|
        %Q(<script src="#{path}"></script>)
      end
    end

    def stylesheet_tag(source, options = {})
      asset_tag(source, { :ext => 'css' }.merge(options)) do |path|
        %Q(<link rel="stylesheet" href="#{path}">)
      end
    end

    # Computes the path to a audio asset either in the Sprockets environment
    # or the public directory. External URIs are untouched.
    #
    # ==== Examples
    #
    # With files within Sprockets:
    #
    #   audio_path 'audio.mp3'            # => '/assets/audio.mp3'
    #   audio_path 'subfolder/audio.mp3'  # => '/assets/subfolder/audio.mp3'
    #   audio_path '/subfolder/audio.mp3' # => '/assets/subfolder/audio.mp3'
    #
    # With files outside of Sprockets:
    #
    #   audio_path 'audio'                                # => '/audios/audio'
    #   audio_path 'audio.mp3'                            # => '/audios/audio.mp3'
    #   audio_path 'subfolder/audio.mp3'                  # => '/audios/subfolder/audio.mp3'
    #   audio_path '/subfolder/audio.mp3                  # => '/subfolder/audio.mp3'
    #   audio_path 'http://www.example.com/img/audio.mp3' # => 'http://www.example.com/img/audio.mp3'
    #
    def audio_path(source, options = {})
      asset_path source, { :dir => 'audios' }.merge(options)
    end
    alias_method :path_to_audio, :audio_path

    # Computes the path to a font asset either in the Sprockets environment
    # or the public directory. External URIs are untouched.
    #
    # ==== Examples
    #
    # With files within Sprockets:
    #
    #   font_path 'font.ttf'            # => '/assets/font.ttf'
    #   font_path 'subfolder/font.ttf'  # => '/assets/subfolder/font.ttf'
    #   font_path '/subfolder/font.ttf' # => '/assets/subfolder/font.ttf'
    #
    # With files outside of Sprockets:
    #
    #   font_path 'font'                                # => '/fonts/font'
    #   font_path 'font.ttf'                            # => '/fonts/font.ttf'
    #   font_path 'subfolder/font.ttf'                  # => '/fonts/subfolder/font.ttf'
    #   font_path '/subfolder/font.ttf                  # => '/subfolder/font.ttf'
    #   font_path 'http://www.example.com/img/font.ttf' # => 'http://www.example.com/img/font.ttf'
    #
    def font_path(source, options = {})
      asset_path source, { :dir => 'fonts' }.merge(options)
    end
    alias_method :path_to_font, :font_path

    # Computes the path to an image asset either in the Sprockets environment
    # or the public directory. External URIs are untouched.
    #
    # ==== Examples
    #
    # With files within Sprockets:
    #
    #   image_path 'edit.png'        # => '/assets/edit.png'
    #   image_path 'icons/edit.png'  # => '/assets/icons/edit.png'
    #   image_path '/icons/edit.png' # => '/assets/icons/edit.png'
    #
    # With files outside of Sprockets:
    #
    #   image_path 'edit'                                # => '/images/edit'
    #   image_path 'edit.png'                            # => '/images/edit.png'
    #   image_path 'icons/edit.png'                      # => '/images/icons/edit.png'
    #   image_path '/icons/edit.png'                     # => '/icons/edit.png'
    #   image_path 'http://www.example.com/img/edit.png' # => 'http://www.example.com/img/edit.png'
    #
    def image_path(source, options = {})
      asset_path source, { :dir => 'images' }.merge(options)
    end
    alias_method :path_to_image, :image_path

    # Computes the path to a javascript asset either in the Sprockets
    # environment or the public directory. If the +source+ filename has no extension,
    # <tt>.js</tt> will be appended. External URIs are untouched.
    #
    # ==== Examples
    #
    # For files within Sprockets:
    #
    #   javascript_path 'xmlhr'        # => '/assets/xmlhr.js'
    #   javascript_path 'dir/xmlhr.js' # => '/assets/dir/xmlhr.js'
    #   javascript_path '/dir/xmlhr'   # => '/assets/dir/xmlhr.js'
    #
    # For files outside of Sprockets:
    #
    #   javascript_path 'xmlhr'                              # => '/javascripts/xmlhr.js'
    #   javascript_path 'dir/xmlhr.js'                       # => '/javascripts/dir/xmlhr.js'
    #   javascript_path '/dir/xmlhr'                         # => '/dir/xmlhr.js'
    #   javascript_path 'http://www.example.com/js/xmlhr'    # => 'http://www.example.com/js/xmlhr'
    #   javascript_path 'http://www.example.com/js/xmlhr.js' # => 'http://www.example.com/js/xmlhr.js'
    #
    def javascript_path(source, options = {})
      asset_path source, { :dir => 'javascripts', :ext => 'js' }.merge(options)
    end
    alias_method :path_to_javascript, :javascript_path

    # Computes the path to a stylesheet asset either in the Sprockets
    # environment or the public directory. If the +source+ filename has no extension,
    # <tt>.css</tt> will be appended. External URIs are untouched.
    #
    # ==== Examples
    #
    # For files within Sprockets:
    #
    #   stylesheet_path 'style'          # => '/assets/style.css'
    #   stylesheet_path 'dir/style.css'  # => '/assets/dir/style.css'
    #   stylesheet_path '/dir/style.css' # => '/assets/dir/style.css'
    #
    # For files outside of Sprockets:
    #
    #   stylesheet_path 'style'                                  # => '/stylesheets/style.css'
    #   stylesheet_path 'dir/style.css'                          # => '/stylesheets/dir/style.css'
    #   stylesheet_path '/dir/style.css'                         # => '/dir/style.css'
    #   stylesheet_path 'http://www.example.com/css/style'       # => 'http://www.example.com/css/style'
    #   stylesheet_path 'http://www.example.com/css/style.css'   # => 'http://www.example.com/css/style.css'
    #
    def stylesheet_path(source, options = {})
      asset_path source, { :dir => 'stylesheets', :ext => 'css' }.merge(options)
    end
    alias_method :path_to_stylesheet, :stylesheet_path

    # Computes the path to a video asset either in the Sprockets environment
    # or the public directory. External URIs are untouched.
    #
    # ==== Examples
    #
    # With files within Sprockets:
    #
    #   video_path 'video.mp4'            # => '/assets/video.mp4'
    #   video_path 'subfolder/video.mp4'  # => '/assets/subfolder/video.mp4'
    #   video_path '/subfolder/video.mp4' # => '/assets/subfolder/video.mp4'
    #
    # With files outside of Sprockets:
    #
    #   video_path 'video'                                # => '/videos/video'
    #   video_path 'video.mp4'                            # => '/videos/video.mp4'
    #   video_path 'subfolder/video.mp4'                  # => '/videos/subfolder/video.mp4'
    #   video_path '/subfolder/video.mp4                  # => '/subfolder/video.mp4'
    #   video_path 'http://www.example.com/img/video.mp4' # => 'http://www.example.com/img/video.mp4'
    #
    def video_path(source, options = {})
      asset_path source, { :dir => 'videos' }.merge(options)
    end
    alias_method :path_to_video, :video_path

    protected

    # Returns the Sprockets environment #asset_path uses to search for
    # assets. This can be overridden for more control, if necessary.
    # Defaults to Sprockets::Helpers.environment or the envrionment
    # returned by #environment.
    def assets_environment
      Helpers.environment || environment
    end
  end

  class Context
    include Helpers
  end
end
