
include Sinatra::AppHelpers

class InstalledFont

  def initialize(rawname)
    @rawname = rawname
  end

  def create!(tmpfile, ext='.ttf')
    @name     = rawname
    @id       = Sinatra::AppHelpers.random
    @rawname  = "#{rawname}-#{id}" if exists?
    @path     = nil

    tmpfile_path = File.expand_path( tmpfile.path )

    FileUtils.mkdir(path)
    path = (ext == '.ttf') ? ttf_path : otf_path
    FileUtils.mv(tmpfile_path, path)
    process!
  end

  def rawname
    @rawname
  end

  def base
    @base || File.join(GENERATED_PATH, rawname)
  end

  def name
    # corresponds to filename
    @name || metadata[:name]
  end

  def fontname
    return @fontname if @fontname
    return metadata[:fontname] if metadata and metadata[:fontname]
    @fontname =  `#{FUSION_PATH} -script #{NAME_SCRIPT_PATH} '#{ttf_path}'`.strip if ttf?
    @fontname = `#{FUSION_PATH} -script #{NAME_SCRIPT_PATH} '#{otf_path}'`.strip if otf?
    set_data(:fontname, @fontname)
    @fontname
  end

  def display_name
    (fontname && fontname.length > 1) ? fontname : name
  end

  def hashed_fontname
    Digest::MD5.hexdigest(fontname)
  end

  def id
    return @id if @id

    id = metadata[:id]
    set_data(:id, Sinatra::AppHelpers.random) if not id
    @id = id
  end

  def path
    File.join(GENERATED_PATH, rawname)
  end

  def metadata
    return @metadata if @metadata

    return false if !File.exists?(meta_path)

    metadata  = YAML::load File.read(meta_path)
    metadata  = metadata.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
    @metadata = metadata
    @metadata
  end

  def exists?
    File.exists?(path)
  end

  def ttf_path_clean
    File.join(base, "#{name}-clean.ttf")
  end

  def ttf_path
    File.join(base, "#{name}.ttf")
  end

  def otf_path
    File.join(base, "#{name}.otf")
  end

  def web_friendly_path
    File.join(base, "#{name}-web-friendly.ttf")
  end

  def autohinted_path
    File.join(base, "#{name}-autohinted.ttf")
  end

  def name_normalized_path
    File.join(base, "#{name}-name-normalized.ttf")
  end

  def woff_path
    File.join(base, "#{name}.woff")
  end

  def eot_path
    File.join(base, "#{name}.eot")
  end

  def eot_lite_path
    File.join(base, "#{name}.eotlite")
  end

  def svg_path
    File.join(base, "#{name}.svg")
  end

  def css_path
    File.join(base, "font.css")
  end

  def preview_path(prepend="")
    File.join(base, prepend + "preview.html")
  end

  def meta_path
    File.join(base, 'data.yaml')
  end

  def afm_path
    File.join(base, "#{name}.afm")
  end

  def ttf_clean?
    File.exists?(ttf_path_clean)
  end

  def ttf?
    File.exists?(ttf_path)
  end

  def otf?
    File.exists?(otf_path)
  end

  def web_friendly?
    File.exists?(web_friendly_path)
  end

  def woff?
    File.exists?(woff_path)
  end

  def eot?
    File.exists?(eot_path)
  end

  def svg?
    File.exists?(svg_path)
  end

  def css?
    File.exists?(css_path)
  end

  def metadata?
    File.exists?(meta_path)
  end

  def average_size
    return metadata[:avg_size] if metadata && metadata[:avg_size]
    sizes = [0]
    sizes <<  File.size(ttf_path)   if ttf?
    sizes <<  File.size(otf_path)   if otf?
    sizes <<  File.size(woff_path)  if woff?
    sizes <<  File.size(eot_path)   if eot?
    sizes <<  File.size(svg_path)   if svg?
    avg_b = sizes.inject{ |sum, el| sum + el }.to_f / sizes.size
    avg_size = avg_b/1024
    set_data(:avg_size, avg_size)
  end

  def character_count
    @character_count ||= characters.length
  end

  def characters
    return @characters if @characters
    return @metadata[:characters] if @metadata && @metadata[:characters]

    chars = `#{FUSION_PATH} -script #{CHARS_SCRIPT_PATH} '#{ttf_path}'`
    chars = chars.split(' ')
    set_data(:characters, chars)

    @characters = chars
    @characters
  end

  def process!(except=[])
    puts " ** Processing #{name}"
    make_metadata       unless metadata?
    make_ttf_clean
    make_ttf            unless ttf?
    make_otf            unless otf?
    make_web_friendly!
    make_woff           unless woff?
    make_eot            unless eot?
    make_svg            unless svg?
    make_css            unless css?
  end

  def make_ttf_clean

    if ttf?
      FileUtils.mv ttf_path, ttf_path_clean
      return
    end

    system "#{FUSION_PATH} -script #{CONVERT_SCRIPT_PATH} '#{otf_path}' '#{ttf_path_clean}'"
  end

  def make_ttf

    if ttf_clean?
      FileUtils.cp ttf_path_clean, ttf_path
      return
    end

    system "#{FUSION_PATH} -script #{CONVERT_SCRIPT_PATH} '#{otf_path}' '#{ttf_path}'"
  end

  def make_otf
    system "#{FUSION_PATH} -script #{CONVERT_SCRIPT_PATH} '#{ttf_path_clean}' '#{otf_path}'"
  end

  def make_web_friendly!(to=ttf_path, from=ttf_path_clean)

    puts "Normalizing names......."
    system "#{FUSION_PATH} -script #{NORMALIZE_NAMES_SCRIPT_PATH} '#{from}' '#{name_normalized_path}'"
    FileUtils.rm_f(to) if File.exists?(to)
    FileUtils.mv(name_normalized_path, to)

    if FP::Database.data[:settings][:webfriendly]
      puts "Making webfriendly......."
      system "#{FUSION_PATH} -script #{WEBFONT_SCRIPT_PATH} '#{from}' '#{web_friendly_path}'"
      FileUtils.rm_f(to) if File.exists?(to)
      FileUtils.mv(web_friendly_path, to)
    end

    if FP::Database.data[:settings][:autohint]
      puts "Autohinting......."
      system "#{FUSION_PATH} -script #{AUTOHINT_SCRIPT_PATH} '#{ttf_path}' '#{autohinted_path}'"
      FileUtils.rm_f(to) if File.exists?(to)
      FileUtils.mv(autohinted_path, to)
    end
  end

  def subset!(selections=false)
    return unless selections

    script  = File.read(SUBSET_SCRIPT_PATH)

    # Assign unicode values to all glyphs.
    u       = selections.map{ |c|
                uni = "0x" + c.to_i.to_s(16)
                [   "SelectIf(", uni, ");", "SetUnicodeValue(", uni, ");"].join('')
              }.join("\n");

    # Add gylphs to selection.
    s       = selections.map{ |c|
                uni = "0x" + c.to_i.to_s(16)
                [   "SelectMoreIf(", uni, ");" ].join('')
              }.join("\n");

    # Generate output.
    script  = script.gsub('[selections]', s)
    script  = script.gsub('[unicode_assignments]', u)

    system "#{FUSION_PATH} -lang=ff -c '#{script}' '#{ttf_path}' '#{ttf_path}-subset'"
    FileUtils.mv "#{ttf_path}-subset", ttf_path
    cleanup_afm
  end

  def make_woff
    system "#{FUSION_PATH} -script #{CONVERT_SCRIPT_PATH} '#{ttf_path}' '#{woff_path}'"
  end

  def make_eot
    # system "#{FUSION_PATH} -script #{CONVERT_SCRIPT_PATH} '#{ttf_path}' '#{eot_path}'"
    if File.exists?( PYTHON_PATH )
      system "#{PYTHON_PATH} #{EOT_LITE_PATH} '#{ttf_path}' '#{eot_path}'"
      FileUtils.mv eot_lite_path, eot_path
    else
      system "#{TITO_PATH} < '#{ttf_path}' > '#{eot_path}'"
    end
  end

  def make_svg
    system "#{FUSION_PATH} -script #{CONVERT_SCRIPT_PATH} '#{ttf_path}' '#{svg_path}'"
    cleanup_svg
  end

  def cleanup_svg
    c = File.read(svg_path)
    c = c.gsub("<svg>", '<svg xmlns="http://www.w3.org/2000/svg">')
    c = c.gsub(/id=\".*\"/i, "id=\"#{hashed_fontname}\" horiz-adv-x='1024'")
    c = c.gsub(/(fontforge)/i, 'FontPrep')
    c = c.gsub(/\<metadata\>.*?\<\/metadata>/, "<metadata></metadata>")
    File.open(svg_path, 'w') {|f| f.write(c) }
  end

  def make_svgs
    `#{FUSION_PATH} -script #{SVGS_SCRIPT_PATH} '#{ttf_path_clean}' '#{base}'`
  end

  def make_css
    css       = File.read(FONT_EXPORT_TEMPLATE_PATH)

    css_family = FP::Database.data[:settings][:use_font_family] ? family : fontname
    css.gsub!('[family]', css_family)

    css.gsub!('[name]', name)
    css.gsub!('[weight]', weight)
    css.gsub!('[style]', style)
    css.gsub!('[id]', hashed_fontname)
    File.open(css_path, 'w') { |file| file.write( css ) }
    css
  end

  def make_preview(prepend="")
    html       = File.read(FONT_EXPORT_PREVIEW_PATH)
    css_family = FP::Database.data[:settings][:use_font_family] ? family : fontname
    html.gsub!('[family]', css_family)
    html.gsub!('[name]', display_name)
    File.open(preview_path(prepend), 'w') { |file| file.write( html ) }
  end

  def make_metadata
    write_metadata(base_metadata)
  end

  def write_metadata(data)
    File.open(meta_path, 'w+') {|f| f.write(data.to_yaml) }
  end

  def base_metadata
    {
      :timestamp  => Time.now().strftime('%A, %B %l, %Y'),
      :name       => name,
      :id         => id
    }
  end

  def set_data(key, val)
    data = metadata
    data[key.to_sym] = val
    write_metadata(data)
  end

  def cleanup_afm
    FileUtils.rm_rf afm_path
  end

  def destroy!
    FileUtils.rm_rf( File.join(TRASH_PATH,rawname) ) if File.exists?(File.join(TRASH_PATH,rawname))
    FileUtils.mv(path, TRASH_PATH, :force => true)
  end

  def install!
    path = ttf_clean? ? ttf_path_clean : ttf_path
    FileUtils.cp ttf_path, SYSTEM_FONT_PATH
  end

  def self.all
    fonts = {}
    Dir.entries( GENERATED_PATH ).select do |dir|
      next if ['.', '..'].include?(dir)
      next if !File.directory?(File.join(GENERATED_PATH, dir))
      font = InstalledFont.new(dir)

      next if !font.metadata?

      fonts[font.id] = font
    end
    fonts
  end

  def self.all_as_array
    a = all.map{ |k,v| v }
    a = a.sort{ |a,b|
     b_name = b.display_name.downcase
     a_name = a.display_name.downcase
     a_name <=> b_name
    }
    a
  end

  def self.find_by_id(id)
    self.all[id]
  end

  def self.find_by_ids(ids)
    fonts = self.all.select { |key, value| ids.include? key }
    fonts = fonts.map {|key, value| value }
    fonts
  end

  def vendor_id
    path = ttf? ? ttf_path : otf_path
    id = `#{FUSION_PATH} -script #{VEND_SCRIPT_PATH} '#{path}'`
    id.strip.upcase
  end

  def blacklisted?
    " ** Checking for blacklist: #{vendor_id} "
    FP_BLACKLIST.include? vendor_id
  end

  def with_path(dir, keep_ttf=true, keep_ttf_clean=false, &block)
    make_ttf_clean unless ttf_clean?
    old_base  = base
    ttf       = ttf_path
    ttf_c     = ttf_path_clean

    @base     = dir
    FileUtils.cp ttf, base
    FileUtils.cp ttf_c, base

    self.instance_eval(&block)

    FileUtils.rm_rf ttf_path unless keep_ttf
    FileUtils.rm_rf ttf_path_clean unless keep_ttf_clean
    @base     = old_base
  end

  def weight
    return @weight if @weight
    return metadata[:weight] if metadata and metadata[:weight]

    normalized_name       = name.downcase
    normalized_fontname   = fontname.downcase

    bold      = /bold|dark/
    light     = /light|thin/
    regular   = /regular|medium/

    @weight = "400"

    if    normalized_name =~ light    or normalized_fontname =~ light
      @weight = "200"
    elsif normalized_name =~ regular  or normalized_fontname =~ regular
      @weight = "400"
    elsif normalized_name =~ bold     or normalized_fontname =~ bold
      @weight = "700"
    end

    set_data(:weight, @weight)
    @weight
  end

  def style
    return @style if @style
    return metadata[:style] if metadata and metadata[:style]

    normalized_name       = name.downcase
    normalized_fontname   = fontname.downcase

    @style = 'normal'
    if    normalized_name =~ /italic/  or normalized_fontname =~ /italic/
      @style = "italic"
    elsif normalized_name =~ /oblique/  or normalized_fontname =~ /oblique/
      @style = "oblique"
    end

    set_data(:style, @style)
    @style
  end

  def family
    return @family if @family
    return metadata[:family] if metadata and metadata[:family]

    @family = `#{FUSION_PATH} -script #{FAMILY_SCRIPT_PATH} '#{ttf_path_clean}'`.strip
    @family = @family.length > 1 ? @family : fontname

    set_data(:family, @family)
    @family
  end

end