class CheckerHelper
  @@tmpdir = nil

  def self.use_tmp()
    @@tmpdir = File.expand_path(File.dirname(__FILE__) + "/../tmp/home")
    FileUtils.rm_rf(@@tmpdir)
    FileUtils.mkpath(@@tmpdir)
    Checker.home_directory = @@tmpdir
  end

  def self.tmp_dir()
    @@tmpdir
  end

  def self.reset()
    FileUtils.rm_rf(@@tmpdir) unless @@tmpdir.nil?
    Checker.home_directory = nil
    @@tmpdir = nil
  end

  def self.latest
    return "spec/tmp/latest"
  end

  def self.deferment
    return 1
  end

  def self.set_latest(maj, min, bui)
    major, minor, build = HP::Cloud::Checker.split(HP::Cloud::VERSION)
    major = (major.to_i + maj).to_s
    minor = (minor.to_i + min).to_s
    build = (build.to_i + bui).to_s
    FileUtils.rm_rf(CheckerHelper.latest)
    f = File.new(CheckerHelper.latest, "w")
    f.write(major + "." + minor + "." + build)
    f.close
  end
end
