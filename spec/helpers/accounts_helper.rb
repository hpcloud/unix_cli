# encoding: utf-8
#
# © Copyright 2013 Hewlett-Packard Development Company, L.P.
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

class AccountsHelper
  @@flavor_id = nil
  @@image_id = nil
  @@win_image_id = nil
  @@username = {}
  @@tmpdir = nil
  @@account = nil

  def self.get_account
    return @@account unless @@account.nil?
    @@account = HP::Cloud::Config.new.get(:default_account)
    @@account
  end

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
    acct = HP::Cloud::Accounts.new.get(get_account())
    @@flavor_id = acct[:options][:preferred_flavor] || "set options flavor in default acct"
    return @@flavor_id
  end

  def self.get_image_id()
    return @@image_id unless @@image_id.nil?
    acct = HP::Cloud::Accounts.new.get(get_account())
    @@image_id = acct[:options][:preferred_image] || "set options image in default acct"
    return @@image_id
  end

  def self.get_win_image_id()
    return @@win_image_id unless @@win_image_id.nil?
    acct = HP::Cloud::Accounts.new.get(get_account())
    @@win_image_id = acct[:options][:preferred_win_image] || "set options win_image in default acct"
    return @@win_image_id
  end

  def self.get_username(name=nil)
    name = get_account if name.nil?
    return @@username[name] unless @@username[name].nil?
    acct = HP::Cloud::Accounts.new.get(name)
    @@username[name] = acct[:username] || "set options username in secondary acct"
    return @@username[name]
  end

  def self.get_uri()
    acct = HP::Cloud::Accounts.new.get(get_account())
    return acct[:credentials][:auth_uri]
  end
end
