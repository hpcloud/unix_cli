require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Acl construction" do
  context "r and user" do
    it "permissions and users are set correctly" do
      acl = Acl.new("r", ["elliott@newmoon.com"])

      acl.is_valid?.should be_true
      acl.is_public?.should be_false
      acl.permissions.should eq("r")
      acl.users.should eq(["elliott@newmoon.com"])
      acl.to_s.should eq("r for elliott@newmoon.com")
      acl.xreaders.should eq("*:elliott@newmoon.com")
      acl.xwriters.should be_nil
      acl.cstatus.message.should be_nil
      acl.cstatus.error_code.should eq(:success)
    end
  end
  context "rw and user" do
    it "permissions and users are set correctly" do
      acl = Acl.new("rw", ["elliott@newmoon.com"])

      acl.is_valid?.should be_true
      acl.is_public?.should be_false
      acl.permissions.should eq("rw")
      acl.users.should eq(["elliott@newmoon.com"])
      acl.to_s.should eq("rw for elliott@newmoon.com")
      acl.xreaders.should eq("*:elliott@newmoon.com")
      acl.xwriters.should eq("*:elliott@newmoon.com")
      acl.cstatus.message.should be_nil
      acl.cstatus.error_code.should eq(:success)
    end
  end
  context "w and user" do
    it "permissions and users are set correctly" do
      acl = Acl.new("w", ["elliott@newmoon.com"])

      acl.is_valid?.should be_true
      acl.is_public?.should be_false
      acl.permissions.should eq("w")
      acl.users.should eq(["elliott@newmoon.com"])
      acl.to_s.should eq("w for elliott@newmoon.com")
      acl.xreaders.should be_nil
      acl.xwriters.should eq("*:elliott@newmoon.com")
      acl.cstatus.message.should be_nil
      acl.cstatus.error_code.should eq(:success)
    end
  end
  context "private and user" do
    it "permissions and users are set correctly" do
      acl = Acl.new("private", ["elliott@newmoon.com"])

      acl.is_valid?.should be_false
      acl.is_public?.should be_false
      acl.permissions.should eq("private")
      acl.users.should eq(["elliott@newmoon.com"])
      acl.to_s.should eq("private for elliott@newmoon.com")
      acl.xreaders.should be_nil
      acl.xwriters.should be_nil
      acl.cstatus.message.should eq("Use the acl:revoke command to revoke public read permissions")
      acl.cstatus.error_code.should eq(:incorrect_usage)
    end
  end
  context "public-read and user" do
    it "permissions and users are set correctly" do
      acl = Acl.new("public-read", ["elliott@newmoon.com"])

      acl.is_valid?.should be_true
      acl.is_public?.should be_false
      acl.permissions.should eq("r")
      acl.users.should eq(["elliott@newmoon.com"])
      acl.to_s.should eq("r for elliott@newmoon.com")
      acl.xreaders.should eq("*:elliott@newmoon.com")
      acl.xwriters.should be_nil
      acl.cstatus.message.should be_nil
      acl.cstatus.error_code.should eq(:success)
    end
  end
  context "RW and user" do
    it "permissions and users are set correctly" do
      acl = Acl.new("RW", ["elliott@newmoon.com"])

      acl.is_valid?.should be_true
      acl.is_public?.should be_false
      acl.permissions.should eq("rw")
      acl.users.should eq(["elliott@newmoon.com"])
      acl.to_s.should eq("rw for elliott@newmoon.com")
      acl.xreaders.should eq("*:elliott@newmoon.com")
      acl.xwriters.should eq("*:elliott@newmoon.com")
      acl.cstatus.message.should be_nil
      acl.cstatus.error_code.should eq(:success)
    end
  end
  context "bogus and user" do
    it "error set" do
      acl = Acl.new("bogus", ["elliott@newmoon.com","edward@sharpe.com"])

      acl.is_valid?.should be_false
      acl.is_public?.should be_false
      acl.permissions.should eq("bogus")
      acl.users.should eq(["elliott@newmoon.com","edward@sharpe.com"])
      acl.to_s.should eq("bogus for elliott@newmoon.com,edward@sharpe.com")
      acl.xreaders.should be_nil
      acl.xwriters.should be_nil
      acl.cstatus.message.should eq("Your permissions 'bogus' are not valid.\nValid settings are: r, rw, w")
      acl.cstatus.error_code.should eq(:incorrect_usage)
    end
  end
  context "r for public" do
    it "error set" do
      acl = Acl.new("r", nil)

      acl.is_valid?.should be_true
      acl.is_public?.should be_true
      acl.permissions.should eq("pr")
      acl.users.should be_nil
      acl.to_s.should eq("public-read")
      acl.xreaders.should eq(".r:*,.rlistings")
      acl.xwriters.should be_nil
      acl.cstatus.message.should be_nil
      acl.cstatus.error_code.should eq(:success)
    end
  end
  context "r for public" do
    it "error set" do
      acl = Acl.new("r", [""])

      acl.is_valid?.should be_true
      acl.is_public?.should be_true
      acl.permissions.should eq("pr")
      acl.users.should be_nil
      acl.to_s.should eq("public-read")
      acl.cstatus.message.should be_nil
      acl.xreaders.should eq(".r:*,.rlistings")
      acl.xwriters.should be_nil
      acl.cstatus.error_code.should eq(:success)
    end
  end
  context "rw for public" do
    it "error set" do
      acl = Acl.new("rw", [""])

      acl.is_valid?.should be_false
      acl.is_public?.should be_true
      acl.permissions.should eq("rw")
      acl.users.should be_nil
      acl.to_s.should eq("rw")
      acl.xreaders.should eq(".r:*,.rlistings")
      acl.xwriters.should eq(".r:*,.rlistings")
      acl.cstatus.message.should eq("You may not make an object writable by everyone")
      acl.cstatus.error_code.should eq(:not_supported)
    end
  end
  context "w for public" do
    it "error set" do
      acl = Acl.new("w", [""])

      acl.is_valid?.should be_false
      acl.is_public?.should be_true
      acl.permissions.should eq("w")
      acl.users.should be_nil
      acl.to_s.should eq("w")
      acl.xreaders.should be_nil
      acl.xwriters.should eq(".r:*,.rlistings")
      acl.cstatus.message.should eq("You may not make an object writable by everyone")
      acl.cstatus.error_code.should eq(:not_supported)
    end
  end
end
