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

  def self.contents(name)
    file_name = @@tmpdir + "/.hpcloud/accounts/" + name
    return File.read(file_name)
  end

  def self.get_flavor_id()
    acct = HP::Cloud::Accounts.new.get('primary')
    return acct[:options][:flavor] || "set options flavor in primary account"
  end

  def self.get_image_id()
    acct = HP::Cloud::Accounts.new.get('primary')
    return acct[:options][:image] || "set options image in primary account"
  end

  def self.get_uri()
    acct = HP::Cloud::Accounts.new.get('primary')
    return acct[:credentials][:auth_uri]
  end
end
