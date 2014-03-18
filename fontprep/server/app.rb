
FONTPREP_PORT             = ENV['PORT'] || 7500

####################################################
# Load in gems
####################################################

Dir.glob(File.join(File.dirname(__FILE__), "vendor", "gems", "*","lib")).each do |lib|
  $LOAD_PATH.unshift File.expand_path(lib)
end

####################################################
# Requires
####################################################

require 'rack'
require 'sinatra'
require 'compass'
require 'compass-normalize'
require 'susy'
require 'haml'
require 'sprockets'
require 'sprockets-sass'
require 'sprockets-helpers'
require 'uglifier'
require 'json'

Dir.glob('./application/**/*.rb') do |file|
  require file
end

WEBRICK_HANDLER         = Rack::Handler::WEBrick

####################################################
# Build FontPrep.
####################################################

FontPrep.initialize_app!

####################################################
# Main FontPrep Sinatra Class.
####################################################

class FPApp < Sinatra::Base

  register Sinatra::FPLicense
  register Sinatra::FPMisc
  register Sinatra::FPApplescript
  register Sinatra::FPUploader
  register Sinatra::FPFont
  register Sinatra::FPFontFiles

  helpers Sinatra::RequestHelpers
  helpers Sinatra::AppHelpers
  helpers Sprockets::Helpers

  # = Configuration =
  set :run,             false
  set :views,           './application/views'
  set :stylesheets,     './application/assets/stylesheets'
  set :javascripts,     './application/assets/javascripts'
  set :fonts,           './application/assets/fonts'
  set :logging,         true
  set :static,          true
  set :haml,            :format => :html5
  set :port,            ENV['PORT'] || 7500

  app = YAML.load(File.read("app.yaml"))
  set :app_values, app

  before do
    cache_control 'no-cache'
  end

  get '/' do
    haml :app
  end

  get '/view/:id' do |id|
    @font = InstalledFont.find_by_id(id)
    haml :viewer
  end

end


####################################################
# Map Sinatra & Sprockets via Rack.
####################################################

app = Rack::Builder.new do
  # Sprockets
  map Sinatra::Application.settings.assets_prefix do
    run Sinatra::Application.sprockets
  end

  # Sinatra app
  map "/" do
    run FPApp.new
  end
end.to_app

# Trap signals to invoke the shutdown procedure cleanly
['INT', 'TERM'].each { |signal|
   trap(signal){
    WEBRICK_HANDLER.shutdown
    exit!
  }
}

########################################################
# Use FontPrep Runner to conditionally run FontPrep.
########################################################

FontPrepRunner.run do
  puts " [FONTPREP] Fontprep is now running on port #{FONTPREP_PORT}."
  WEBRICK_HANDLER.run app, :Port => FONTPREP_PORT, :Host => "0.0.0.0"
  exit!
end

