class AuthCacheHelper
  @@tmpdir = nil

  def self.use_fixtures()
    home = File.expand_path(File.dirname(__FILE__) + "/../fixtures/accounts/.cache")
    AuthCache.home_directory = home
  end

  def self.use_tmp()
    @@tmpdir = File.expand_path(File.dirname(__FILE__) + "/../tmp/home")
    FileUtils.rm_rf(@@tmpdir)
    FileUtils.mkpath(@@tmpdir)
    AuthCache.home_directory = @@tmpdir
  end

  def self.tmp_dir()
    @@tmpdir
  end

  def self.reset()
    FileUtils.rm_rf(@@tmpdir) unless @@tmpdir.nil?
    AuthCache.home_directory = nil
    @@tmpdir = nil
  end

  def self.contents(name)
    file_name = @@tmpdir + "/.hpcloud/accounts/.cache/" + name
    return File.read(file_name)
  end

  def self.value(name, groupo, key)
    file_name = @@tmpdir + "/.hpcloud/accounts/.cache/" + name
    yaml = YAML::load(File.open(file_name))
    return yaml[groupo][key]
  end
end
