DB_VERSION = 2.1

module FP 
  class Database

    def self.data
      data  = YAML::load(File.read(DATABASE_PATH))
      return {} if !data
      data  = data.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
      data
    end

    def self.create

      if not File.exists?(DATABASE_PATH)
        FileUtils.touch(DATABASE_PATH)
        self.reset!
      end

      if not (self.data[:version] == self.version)
        self.reset!
      end
    end

    def self.reset!
      d = self.defaults.deep_merge(self.data)
      d[:version] = DB_VERSION

      File.open(DATABASE_PATH, 'w+') {|f| f.write(d.to_yaml) }
    end

    def self.set(key, val)
      data = self.data
      data[key.to_sym] = val
      File.open(DATABASE_PATH, 'w+') {|f| f.write(data.to_yaml) }
    end

    def self.set_setting(key, val)
      data = self.data
      settings = data[:settings]
      settings[key.to_sym] = val
      data[:settings] = settings
      File.open(DATABASE_PATH, 'w+') {|f| f.write(data.to_yaml) }
    end

    def self.defaults
      YAML.load( {
        :settings => {
            :autohint           => true,
            :webfriendly        => true,
            :override_blacklist => true,
            :use_font_family    => true,
            :theme              => 'river'
          },
        :subscription => {
          :email =>     "",
          :license =>   ""
        },
        :export_path => '~/Desktop',
        :version => self.version
      }.to_yaml )
    end

    def self.version
      DB_VERSION
    end

  end
end

class ::Hash
    def deep_merge(second)
        merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
        self.merge(second, &merger)
    end
end