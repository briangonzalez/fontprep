require 'sinatra/base'
require 'haml'

module Sinatra
  module FPUploader

    module Helpers
      def fontrow_haml
        File.read( File.join(settings.views, "partials", '_fontrow.haml' ) )
      end

      def fontdrawer_haml
        File.read( File.join(settings.views, "partials", '_fontdrawer.haml' ) )
      end
    end

    def self.registered(app)
      app.helpers FPUploader::Helpers

      app.post '/upload' do

        html    = ""
        skipped = 0
        count   = 0

        params[:files].each do |file|
          filename  = file[:filename]   
          extname   = File.extname(filename)

          if not ['.ttf', '.otf'].include?(extname.downcase)
            skipped += 1
            puts " ** Not a TTF or OTF, skipping: #{filename}"
            next
          end

          begin
            rawname   = File.basename(filename, extname)  
            font      = InstalledFont.new(rawname) 
            font.create!(file[:tempfile], extname.downcase)

            if !FP::Database.data[:settings][:override_blacklist] and font.blacklisted?
              puts "  ** Not processing, blacklisted: #{filename}"
              puts "  ** Vendor id: #{font.vendor_id}"
              font.destroy!
              skipped += 1
              next
            end

            count += 1

            html << haml( fontrow_haml,    :layout => false, :locals => { :font => font, :imported => true })
            html << haml( fontdrawer_haml, :layout => false, :locals => { :font => font })          
          rescue Exception => e
            puts "  ** Error processing #{filename}"
            puts e
            skipped += 1
          end
  
        end

        content_type :json
        { :message => "Success.", :html => html, :skipped => skipped, :count => count }.to_json
      end

    end
  end

  register FPUploader
end