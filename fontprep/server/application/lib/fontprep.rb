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

  def self.port
    FONTPREP_PORT || 7500
  end

end