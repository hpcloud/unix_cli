class ConfigHelper
  def self.use_fixtures()
    home = File.expand_path(File.dirname(__FILE__) + "/../fixtures/config")
    HP::Cloud::Config.home_directory = home
  end

  def self.tmp_directory()
    @@tmpdir = File.expand_path(File.dirname(__FILE__) + "/../tmp/home")
  end

  def self.use_tmp()
    @@tmpdir = ConfigHelper.tmp_directory()
    FileUtils.rm_rf(@@tmpdir)
    FileUtils.mkpath(@@tmpdir)
    HP::Cloud::Config.home_directory = @@tmpdir
  end

  def self.reset()
    FileUtils.rm_rf(@@tmpdir) unless @@tmpdir.nil?
    HP::Cloud::Config.home_directory = nil
  end
end
