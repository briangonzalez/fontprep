module FP 
  class Export

    def initialize(font)
      @installed_fonts  = font.kind_of?(Array) ? font : [font]
      @path             = File.expand_path( FP::Database.data[:export_path] )
      @path             = File.expand_path( DESKTOP_PATH ) unless File.exists?(@path)
    end

    def export_path
      return @export_path if @export_path
      @export_path = File.join( @path, "fp-export-#{Time.now.to_i}" )
      FileUtils.mkdir(@export_path)
      @export_path
    end

    def webfont_pack(characters=false, simple=false)
      length = @installed_fonts.length

      @installed_fonts.each do |font|
        FileUtils.cp font.otf_path, export_path      
        font.with_path(export_path) do
          make_ttf

          subset!(characters)
          make_web_friendly!(ttf_path, ttf_path)

          make_eot
          make_svg
          make_woff
          FileUtils.rm_rf otf_path   

          unless simple
            prepend = length > 1 ? font.display_name + '-' : '';
            make_preview(prepend)  
          end 
        end
      end
      css unless simple
    end

    def webfont_pack_simple
      webfont_pack(false, true)
    end

    def all(characters=false)
      @installed_fonts.each do |font|
        FileUtils.cp font.otf_path, export_path      
        font.with_path(export_path, true, true) do
          make_metadata
          make_ttf_clean
          make_ttf

          make_web_friendly!
          subset!(characters)

          make_eot
          make_svg
          make_woff
          make_preview
          otf_path      
        end
      end
      css
    end

    def ttf
      @installed_fonts.each do |font|
        font.with_path(export_path, true) do
          make_ttf
        end
      end
    end

    def otf
      @installed_fonts.each do |font|
        font.with_path(export_path, false) do
          make_otf
        end
      end
    end

    def woff
      @installed_fonts.each do |font|
        font.with_path(export_path, false) do
          make_woff
        end        
      end
    end

    def eot
      @installed_fonts.each do |font|
        font.with_path(export_path, false) do
          make_eot
        end        
      end
    end

    def svg
      @installed_fonts.each do |font|
        font.with_path(export_path, false) do
          make_svg
        end        
      end
    end

    def css
      base_css = File.read(FONT_EXPORT_TEMPLATE_PATH)
      css       = ""
      @installed_fonts.each do |font|
        css << font.make_css + "\n\n"
      end

      p = File.join( export_path, "font.css" )
      FileUtils.rm_rf(p)
      File.open(p, 'w') { |file| file.write( css ) }
    end

    def svgs
      @installed_fonts.each do |font|
        font.with_path(export_path, false) do
          font.make_svgs
        end        
      end
    end

  end
end