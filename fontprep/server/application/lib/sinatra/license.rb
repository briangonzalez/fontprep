require 'sinatra/base'

module Sinatra
  module FPLicense

    module Helpers
    end

    def self.registered(app)
      app.helpers FPLicense::Helpers

      app.post '/license' do
        email   = params[:email].strip
        license = params[:license].strip

        halt 401 unless FontPrep.valid_license?(email, license)

        FP::Database.set( :subscription, { :email => email, :license => license })

        content_type :json
        { :msg => 'Success!' }.to_json
      end

    end
  end

  register FPLicense
end