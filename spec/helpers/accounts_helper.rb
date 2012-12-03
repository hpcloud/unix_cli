class AccountsHelper
  @@flavor_id = nil
  @@image_id = nil
  @@win_image_id = nil
  @@username = {}
  @@tmpdir = nil

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

  def self.tmp_dir()
    @@tmpdir
  end

  def self.reset()
    FileUtils.rm_rf(@@tmpdir) unless @@tmpdir.nil?
    Accounts.home_directory = nil
    @@tmpdir = nil
  end

  def self.contents(name)
    file_name = @@tmpdir + "/.hpcloud/accounts/" + name
    return File.read(file_name)
  end

  def self.value(name, groupo, key)
    file_name = @@tmpdir + "/.hpcloud/accounts/" + name
    yaml = YAML::load(File.open(file_name))
    return yaml[groupo][key]
  end

  def self.get_flavor_id()
    return @@flavor_id unless @@flavor_id.nil?
    acct = HP::Cloud::Accounts.new.get('hp')
    @@flavor_id = acct[:options][:preferred_flavor] || "set options flavor in default acct"
    return @@flavor_id
  end

  def self.get_image_id()
    return @@image_id unless @@image_id.nil?
    acct = HP::Cloud::Accounts.new.get('hp')
    @@image_id = acct[:options][:preferred_image] || "set options image in default acct"
    return @@image_id
  end

  def self.get_win_image_id()
    return @@win_image_id unless @@win_image_id.nil?
    acct = HP::Cloud::Accounts.new.get('hp')
    @@win_image_id = acct[:options][:preferred_win_image] || "set options win_image in default acct"
    return @@win_image_id
  end

  def self.get_username(name)
    return @@username[name] unless @@username[name].nil?
    acct = HP::Cloud::Accounts.new.get(name)
    @@username[name] = acct[:username] || "set options username in secondary acct"
    return @@username[name]
  end

  def self.get_uri()
    acct = HP::Cloud::Accounts.new.get('hp')
    return acct[:credentials][:auth_uri]
  end
end
