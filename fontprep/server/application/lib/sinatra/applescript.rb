require 'sinatra/base'

module Sinatra
  module FPApplescript

    module Helpers
      def relative_url
        "http://127.0.0.1:#{settings.port}"
      end

      def copy(text)
        %x[osascript -e 'tell app "Finder" to set the clipboard to "#{text}"']
      end

      def alert(text='Are you sure?')
        response = `osascript -e 'tell app "System Events" to display dialog "#{text}"'`
        !!(response =~ /OK/)
      end

    end

    def self.registered(app)
      app.helpers FPApplescript::Helpers

      app.post '/applescript/open-url' do
        url = relative_url + params[:url]
        %x[osascript -e 'open location "#{url}"']
      end

      app.post '/applescript/copy-character' do
        copy(params[:text].strip)
      end

      app.post '/applescript/alert' do
        response = alert(params[:text])

        content_type :json
        { :result => response }.to_json
      end

    end

  end

  register FPApplescript
end