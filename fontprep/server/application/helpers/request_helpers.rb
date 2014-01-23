# ===================
# = Request Helpers =
# ===================
module Sinatra
  module RequestHelpers

    def space_delimited_path
      p = request.env['REQUEST_PATH']
      p.slice!(0)
      p.gsub! '/', ' '
      p.empty? ? "app" : p
    end

  end

  helpers RequestHelpers
end