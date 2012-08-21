class AccountsHelper
  def self.use_fixtures()
    home = File.expand_path(File.dirname(__FILE__) + "/../fixtures/accounts")
    Accounts.home_directory = home
  end

  def self.use_tmp()
    @@tmpdir = File.expand_path(File.dirname(__FILE__) + "/../tmp/home")
    FileUtils.rm_rf(@@tmpdir)
    FileUtils.mkpath(@@tmpdir)
    Accounts.home_directory = @@tmpdir
  end

  def self.reset()
    FileUtils.rm_rf(@@tmpdir) unless @@tmpdir.nil?
    Accounts.home_directory = nil
  end
end
