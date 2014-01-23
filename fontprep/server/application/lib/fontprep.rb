class FontPrep

  def self.initialize_app!
    self.make_app_dirs_and_files
  end

  def self.make_app_dirs_and_files
    FileUtils.mkdir(APPLICATION_SUPPORT_PATH) unless File.exists?(APPLICATION_SUPPORT_PATH)
    FileUtils.mkdir(GENERATED_PATH)           unless File.exists?(GENERATED_PATH)
    FileUtils.mkdir(DATABASE_DIR)             unless File.exists?(DATABASE_DIR)
    FP::Database.create
  end

  def self.licensed?
    true
  end

  def self.valid_license?(email, license)
    true
  end

  def self.themes
    themes = []
    Dir.glob('./application/assets/stylesheets/partials/themes/*.scss').each do |theme_file|
      name = File.basename(theme_file, ".scss")
      name.gsub!('_theme_', '')
      themes << name
    end
    themes
  end

  def self.set_theme(theme)
    begin
      FileUtils.rm_rf self.default_theme_path
      File.symlink self.theme_path(theme), self.default_theme_path 
      FP::Database.set_setting( :theme, theme)
    rescue Exception => e
      FileUtils.rm_rf self.default_theme_path
      File.symlink self.theme_path('ember'), self.default_theme_path 
      FP::Database.set_setting( :theme, 'ember')   
    end
  end

  def self.default_theme_path
    File.join('application', 'assets', 'stylesheets', 'partials', '_variables_theme.scss')
  end

  def self.theme_path(name)
    "themes/_theme_#{name}.scss"
  end

  def self.port
    FONTPREP_PORT || 7500
  end

end