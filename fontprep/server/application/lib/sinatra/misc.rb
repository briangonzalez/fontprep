require 'sinatra/base'

module Sinatra
  module FPMisc

    module Helpers
      def fontdrawer_characters_haml
        File.read( File.join(settings.views, "partials", '_fontdrawer_characters.haml' ) )
      end

      def fontrows_haml
        File.read( File.join(settings.views, "partials", '_fontrows.haml' ) )
      end

      def select_folder
        raw_path  = %x[osascript -e 'tell app "Finder" to activate' -e 'tell app "Finder" to set myFolder to choose folder ']

        return raw_path if raw_path.empty?

        raw_path  = raw_path.split(/\Aalias/)
        raw_path  = raw_path[1].strip if raw_path.length > 1

        path      = raw_path.gsub ':', '/'
        path      = "/Volumes/#{path}"

        return path
      end

    end

    def self.registered(app)
      app.helpers FPMisc::Helpers

      app.get '/misc/fontrows' do

        begin
          all   = InstalledFont.all_as_array 
          any   = all.empty?
          html  = haml( fontrows_haml, :layout => false, :locals => {:all => all })

          content_type :json
          { :message => "Success.", :html => html, :empty => all.empty? }.to_json
        rescue Exception => e
          raise e
        end
      end

      app.get '/misc/drawer-characters' do
        show_all = params[:all] == 'true' ? true : false

        font = InstalledFont.find_by_id(params[:id]) 
        html = haml( fontdrawer_characters_haml, :layout => false, :locals => { 
                                                                      :font => font, 
                                                                      :show_all => show_all 
                                                                    })

        content_type :json
        { :message => "Success.", :html => html }.to_json
      end

      app.post '/settings/set' do
        value = params[:value]
        value = true  if ['1', 1].include?(value)  
        value = false if ['0', 0].include?(value)

        FP::Database.set_setting( params[:key], value )

        content_type :json
        { :message => "Success."}.to_json
      end

      app.post '/settings/set-path' do
        path  = select_folder
        FP::Database.set( 'export_path', path) if File.exists?(path)

        content_type :json
        { :path => FP::Database.data[:export_path] }.to_json
      end

      app.post '/settings/set-theme' do
        FontPrep.set_theme(params[:theme])

        content_type :json
        { :msg => "Success" }.to_json
      end

      app.get '/ping' do
        'pong'
      end

      app.get '/pid' do
        FontPrepRunner.this_pid.to_s
      end

      app.get '/version' do
        FontPrepRunner.running_version.to_s
      end

      app.get '/kill' do
        exit!
      end

    end
  end

  register FPMisc
end