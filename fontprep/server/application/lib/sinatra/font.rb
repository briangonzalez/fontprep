require 'sinatra/base'

module Sinatra
  module FPFont

    module Helpers
    end

    def self.registered(app)
      app.helpers FPFont::Helpers

      app.post '/font/remove' do
        font      = InstalledFont.find_by_id(params[:id])
        font.destroy!

        content_type :json
        { :name => font.display_name }.to_json
      end

      app.post '/font/remove-all' do
        fonts      = InstalledFont.all
        
        fonts.values.each do |font|
          font.destroy!
        end

        content_type :json
        { :msg => "All deleted" }.to_json
      end

      app.post '/font/export' do
        font        = InstalledFont.find_by_id(params[:id])
        export      = FP::Export.new(font)
        characters  = params[:characters]

        export.send(params[:type])

        content_type :json
        { :name => font.display_name }.to_json
      end

      app.post '/font/export-group' do
        fonts    = InstalledFont.find_by_ids(params[:ids])
        export   = FP::Export.new(fonts)
        export.send(:webfont_pack)
        "Success."
      end

      app.post '/font/export-subset' do
        font        = InstalledFont.find_by_id(params[:id])
        export      = FP::Export.new(font)
        characters  = params[:characters]

        export.webfont_pack(characters)

        content_type :json
        { :name => font.display_name }.to_json
      end

      app.post '/font/install' do
        font = InstalledFont.find_by_id(params[:id])
        font.install!
        
        content_type :json
        { :name => font.display_name }.to_json
      end

    end
  end

  register FPFont
end