# ================
# = App Helpers  =
# ================
module Sinatra
  module AppHelpers

    #   This method slurps in the settings from app.yaml, and places them in 
    #   Sinatra's constant: `settings`. Then you can access them from anywhere via 
    #
    #     app(:some_constant)
    #
    def app(key)
      settings.app_values[key.to_s]
    end

    def random
      (0...10).map{ ('a'..'z').to_a[rand(26)] }.join
    end

    def decimal(hex)
      hex.to_i(16)
    end

    def hex(dec)
      dec.to_i.to_s(16)
    end

    def dec_entity(text)
      "&##{text};"
    end

    def hex_entity(text)
      "&#x#{text};"
    end

  end

  helpers AppHelpers
end