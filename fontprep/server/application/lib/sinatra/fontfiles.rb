require 'sinatra/base'

module Sinatra
  module FPFontFiles

    module Helpers

      def unique_css(id)
        css_file = File.join(settings.stylesheets, "partials", "app", "font_template.css")
        css = File.read(css_file)
        css.gsub!('[id]', id)
        css
      end

    end

    def self.registered(app)
      app.helpers FPFontFiles::Helpers

      app.get %r{/font/file.*} do
        cache_control "nocache"
        id      = params[:id]
        type    = params[:type]
        font    = InstalledFont.find_by_id(id)
        send_file( font.send("#{type}_path") )
      end

      app.get '/font/css' do
        id      = params[:id]
        raw     = params.has_key?("raw")
        chrome  = params.has_key?("chrome")

        if raw
          content_type :css
          css = unique_css(id)
          css = css.gsub("url('", "url('http://localhost:7500") if chrome
          css
        else
          content_type :json
          { :id => id, :css => unique_css(id) }.to_json
        end
      end

      app.get '/font/codes' do
        num = params[:data]
        
        content_type :json
        { :num => num, :hex => hex_entity(hex(num)), :dec => dec_entity(num)  }.to_json
      end

    end
  end

  register FPFontFiles
end