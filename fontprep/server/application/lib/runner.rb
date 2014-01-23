
require 'net/http'

FONTPREP_ORG_STRING       = "com.briangonzalez.org.FontPrep"

class FontPrepRunner

  def self.run
    if block_given? 

      if self.server_in_sync? and self.running? and self.server_healthy? and self.server_has_version?
        puts "\n"
        puts " ** FontPrep server already running and in-sync!"
        puts " ** VERSION: #{self.running_version}"
        puts " ** PID:#{self.running_pid} \n\n"
        exit
      else
        self.kill
        self.write_version
        self.write_pid
        yield
      end

    end
  end

  def self.write_version
    File.open( self.version_file, 'w') {|f| f.write(self.version_to_run) }
  end

  def self.running_version
    pid = File.read( self.version_file ).chomp.to_s
  end

  def self.version_to_run
    version = false
    ARGV.each do |arg|
      arg       = arg.split("=")
      version   = arg[1] if (arg[0] == "VERSION")
    end
    raise " ** Must specify a version; ruby ./app.rb VERSION=" unless version

    version.to_s
  end

  def self.write_pid
    File.open( self.pid_file, 'w') {|f| f.write(self.this_pid) }
  end

  def self.running_pid
    return false if not File.exists? self.pid_file

    pid = File.read( self.pid_file ).chomp
    pid.length < 1 ? false : pid.to_i
  end

  def self.this_pid
    $$
  end

  def self.server_in_sync?
    puts " ** Version last run: #{self.running_version}"
    puts " ** Trying to run: #{self.version_to_run}"
    self.running_version == self.version_to_run
  end

  def self.running?
    p = self.running_pid.to_s
    status  = %x[if ps -p #{p} > /dev/null; then echo "ACTIVE"; else echo "INACTIVE"; fi].chomp
    puts " ** Server running?: #{status}"
    status == "ACTIVE"
  end

  def self.kill_running_pid
    begin
      pid = IO.read( self.pid_file ).chomp
      raise "No PID found." if pid.length == 0
      puts " ** Trying to kill PID: #{pid} at #{ self.pid_file }"
      `kill -9 #{pid}`
      sleep 3
      puts " ** Stopped PID: #{pid} at #{ self.pid_file }"
    rescue => e
      puts " ** Error, process **may** not have stopped: #{self.pid_file}: #{e}"
    end
  end

  protected

  def self.pid_file
    base = ".#{FONTPREP_ORG_STRING}.pid"
    file = File.expand_path( File.join('~', base ) )

    FileUtils.touch(file) unless File.exists? file
    file
  end

  def self.version_file
    base = ".#{FONTPREP_ORG_STRING}.version"
    file = File.expand_path( File.join('~', base ) )

    FileUtils.touch(file) unless File.exists? file
    file
  end

  def self.server_has_version?
    uri         = URI("http://127.0.0.1:#{self.port}/version")
    request     = Net::HTTP.get_response(uri)
    code        = request.response.code
    puts " ** Looking for status code of /version, got: #{code}"
    code[0] == "2"
  end

  def self.server_healthy?
    begin
      uri         = URI("http://127.0.0.1:#{self.port}/pid")
      puts " ** Requesting: #{uri}"
      request     = Net::HTTP.get_response(uri)
      code        = request.response.code

      healthy     = (code[0] == "2")
      puts " ** Server healthy?: #{healthy}"
      healthy  
    rescue Exception => e
      false
    end
  end

  def self.kill_others
    puts " ** Killing old FontPrep servers who may be running on #{port}"
    `curl 127.0.0.1:#{port}/kill`
  end

  def self.kill
    self.kill_running_pid
    self.kill_others
  end

  def self.port
    begin
      FontPrep.port
    rescue Exception => e
      7500
    end
  end

end