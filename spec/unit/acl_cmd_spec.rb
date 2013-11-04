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

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "AclCmd construction" do
  context "r and user" do
    it "permissions and users are set correctly" do
      acl = AclCmd.new("r", ["elliott@newmoon.com"])

      acl.is_valid?.should be_true
      acl.is_public?.should be_false
      acl.permissions.should eq("r")
      acl.users.should eq(["elliott@newmoon.com"])
      acl.readers.should eq(["elliott@newmoon.com"])
      acl.writers.should be_nil
      acl.to_s.should eq("r for elliott@newmoon.com")
      acl.cstatus.message.should be_nil
      acl.cstatus.error_code.should eq(:success)
    end
  end
  context "rw and user" do
    it "permissions and users are set correctly" do
      acl = AclCmd.new("rw", ["elliott@newmoon.com"])

      acl.is_valid?.should be_true
      acl.is_public?.should be_false
      acl.permissions.should eq("rw")
      acl.users.should eq(["elliott@newmoon.com"])
      acl.readers.should eq(["elliott@newmoon.com"])
      acl.writers.should eq(["elliott@newmoon.com"])
      acl.to_s.should eq("rw for elliott@newmoon.com")
      acl.cstatus.message.should be_nil
      acl.cstatus.error_code.should eq(:success)
    end
  end
  context "w and user" do
    it "permissions and users are set correctly" do
      acl = AclCmd.new("w", ["elliott@newmoon.com"])

      acl.is_valid?.should be_true
      acl.is_public?.should be_false
      acl.permissions.should eq("w")
      acl.users.should eq(["elliott@newmoon.com"])
      acl.readers.should be_nil
      acl.writers.should eq(["elliott@newmoon.com"])
      acl.to_s.should eq("w for elliott@newmoon.com")
      acl.cstatus.message.should be_nil
      acl.cstatus.error_code.should eq(:success)
    end
  end
  context "private and user" do
    it "permissions and users are set correctly" do
      acl = AclCmd.new("private", ["elliott@newmoon.com"])

      acl.is_valid?.should be_false
      acl.is_public?.should be_false
      acl.permissions.should eq("private")
      acl.readers.should be_nil
      acl.writers.should be_nil
      acl.users.should eq(["elliott@newmoon.com"])
      acl.to_s.should eq("private for elliott@newmoon.com")
      acl.cstatus.message.should eq("Use the acl:revoke command to revoke public read permissions")
      acl.cstatus.error_code.should eq(:incorrect_usage)
    end
  end
  context "public-read and user" do
    it "permissions and users are set correctly" do
      acl = AclCmd.new("public-read", ["elliott@newmoon.com"])

      acl.is_valid?.should be_true
      acl.is_public?.should be_false
      acl.permissions.should eq("r")
      acl.readers.should eq(["elliott@newmoon.com"])
      acl.writers.should be_nil
      acl.users.should eq(["elliott@newmoon.com"])
      acl.to_s.should eq("r for elliott@newmoon.com")
      acl.cstatus.message.should be_nil
      acl.cstatus.error_code.should eq(:success)
    end
  end
  context "RW and user" do
    it "permissions and users are set correctly" do
      acl = AclCmd.new("RW", ["elliott@newmoon.com"])

      acl.is_valid?.should be_true
      acl.is_public?.should be_false
      acl.permissions.should eq("rw")
      acl.readers.should eq(["elliott@newmoon.com"])
      acl.writers.should eq(["elliott@newmoon.com"])
      acl.users.should eq(["elliott@newmoon.com"])
      acl.to_s.should eq("rw for elliott@newmoon.com")
      acl.cstatus.message.should be_nil
      acl.cstatus.error_code.should eq(:success)
    end
  end
  context "bogus and user" do
    it "error set" do
      acl = AclCmd.new("bogus", ["elliott@newmoon.com","edward@sharpe.com"])

      acl.is_valid?.should be_false
      acl.is_public?.should be_false
      acl.permissions.should eq("bogus")
      acl.readers.should be_nil
      acl.writers.should be_nil
      acl.users.should eq(["elliott@newmoon.com","edward@sharpe.com"])
      acl.to_s.should eq("bogus for elliott@newmoon.com,edward@sharpe.com")
      acl.cstatus.message.should eq("Your permissions 'bogus' are not valid.\nValid settings are: r, rw, w")
      acl.cstatus.error_code.should eq(:incorrect_usage)
    end
  end
  context "r for public" do
    it "error set" do
      acl = AclCmd.new("r", [])

      acl.is_valid?.should be_true
      acl.is_public?.should be_true
      acl.permissions.should eq("pr")
      acl.readers.should eq([])
      acl.writers.should be_nil
      acl.users.should eq([])
      acl.to_s.should eq("public-read")
      acl.cstatus.message.should be_nil
      acl.cstatus.error_code.should eq(:success)
    end
  end
  context "rw for public" do
    it "error set" do
      acl = AclCmd.new("rw", [])

      acl.is_valid?.should be_false
      acl.is_public?.should be_true
      acl.permissions.should eq("rw")
      acl.readers.should eq([])
      acl.writers.should eq([])
      acl.users.should eq([])
      acl.cstatus.message.should eq("You may not make an object writable by everyone")
      acl.cstatus.error_code.should eq(:not_supported)
    end
  end
  context "w for public" do
    it "error set" do
      acl = AclCmd.new("w", [])

      acl.is_valid?.should be_false
      acl.is_public?.should be_true
      acl.permissions.should eq("w")
      acl.readers.should be_nil
      acl.writers.should eq([])
      acl.users.should eq([])
      acl.cstatus.message.should eq("You may not make an object writable by everyone")
      acl.cstatus.error_code.should eq(:not_supported)
    end
  end
end
