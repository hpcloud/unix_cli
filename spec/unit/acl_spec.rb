require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Acl class" do
  KEY = 'X-Container-Read'
  WRITER_KEY = 'X-Container-Write'
  BIG_ONE = {KEY=>'*:ginny,*:ron,*:fred,*:george,*:percy,*:charlie,*:bill'}

  context "parse acl" do
    it "returns true and no error" do
      acl = Acl.new(nil, nil)

      acl.parse_acl("*:terry").should eq(["terry"])
      acl.parse_acl("*:terry,*:bob,*:sue").should eq(["terry","bob","sue"])
      acl.parse_acl(".r:*,.rlist").should eq([])
      acl.parse_acl("*:,").should eq(nil)

      acl.parse_public("*:terry").should eq("no")
      acl.parse_public("*:terry,*:bob,*:sue").should eq("no")
      acl.parse_public(".r:*,.rlist").should eq("yes")
      acl.parse_public("*:,").should eq("no")

      acl.cstatus.is_success?.should be_true
    end
  end

  context "construct nothing" do
    it "permissions and users are set correctly" do
      acl = AclReader.new(nil)

      acl.is_valid?.should be_true
      acl.to_hash.should eq({})
      acl.cstatus.message.should be_nil
      acl.cstatus.error_code.should eq(:success)
    end
  end

  context "construct all" do
    it "permissions and users are set correctly" do
      hsh = {KEY=>'.r:*,.rlistings'}

      acl = AclReader.new(hsh)

      acl.is_valid?.should be_true
      acl.to_hash.should eq(hsh)
    end
  end

  context "construct one" do
    it "permissions and users are set correctly" do
      hsh = {KEY=>'*:bob'}

      acl = AclReader.new(hsh)

      acl.is_valid?.should be_true
      acl.to_hash.should eq(hsh)
    end
  end

  context "construct many" do
    it "permissions and users are set correctly" do
      acl = AclReader.new(BIG_ONE)

      acl.is_valid?.should be_true
      acl.to_hash.should eq(BIG_ONE)
    end
  end

  context "revoke ginny and percy" do
    it "permissions and users are set correctly" do
      acl = AclReader.new(BIG_ONE)

      acl.revoke(["ginny","percy"]).should be_true

      acl.to_hash.should eq({KEY=>"*:ron,*:fred,*:george,*:charlie,*:bill"})
      acl.is_valid?.should be_true
    end
  end

  context "revoke from nothing" do
    it "permissions and users are set correctly" do
      acl = AclReader.new(nil)

      acl.revoke(["ginny","percy"]).should be_false

      acl.to_hash.should eq({})
      acl.is_valid?.should be_false
      acl.cstatus.message.should eq("Revoke failed invalid user: ginny,percy")
      acl.cstatus.error_code.should eq(:not_found)
    end
  end

  context "revoke two of three" do
    it "permissions and users are set correctly" do
      acl = AclReader.new(BIG_ONE)

      acl.revoke(["charlie","hagrid","fred"]).should be_false

      acl.to_hash.should eq({KEY=>"*:ginny,*:ron,*:george,*:percy,*:bill"})
      acl.is_valid?.should be_false
      acl.cstatus.message.should eq("Revoke failed invalid user: hagrid")
      acl.cstatus.error_code.should eq(:not_found)
    end
  end

  context "revoke empty" do
    it "permissions and users are set correctly" do
      acl = AclReader.new(BIG_ONE)

      acl.revoke([]).should be_true

      acl.to_hash.should eq(BIG_ONE)
      acl.is_valid?.should be_true
    end
  end

  context "grant from nothing" do
    it "permissions and users are set correctly" do
      acl = AclReader.new(nil)

      acl.grant(["bob"]).should be_true

      acl.to_hash.should eq({"X-Container-Read"=>"*:bob"})
      acl.is_valid?.should be_true
    end
  end

  context "grant empty" do
    it "permissions and users are set correctly" do
      acl = AclReader.new(BIG_ONE)

      acl.grant([]).should be_true

      acl.to_hash.should eq({KEY=>'.r:*,.rlistings'})
      acl.is_valid?.should be_true
    end
  end

  context "grant one" do
    it "permissions and users are set correctly" do
      acl = AclReader.new({KEY=>"*:ginny,*:ron"})

      acl.grant(["percy"]).should be_true

      acl.to_hash.should eq({KEY=>"*:percy"})
      acl.is_valid?.should be_true
    end
  end

  context "grant many" do
    it "permissions and users are set correctly" do
      acl = AclReader.new({KEY=>"*:ginny,*:ron"})

      acl.grant(["percy","charlie", "bill"]).should be_true

      acl.to_hash.should eq({KEY=>"*:percy,*:charlie,*:bill"})
      acl.is_valid?.should be_true
    end
  end

  context "grant dups" do
    it "permissions and users are set correctly" do
      acl = AclReader.new({KEY=>"*:ginny,*:ron"})

      acl.grant(["percy","ron", "ginny"]).should be_true

      acl.to_hash.should eq({KEY=>"*:percy,*:ron,*:ginny"})
      acl.is_valid?.should be_true
    end
  end

  context "writer grant dups" do
    it "permissions and users are set correctly" do
      acl = AclWriter.new({WRITER_KEY=>"*:ginny,*:ron"})

      acl.grant(["percy","ron", "ginny"]).should be_true

      acl.to_hash.should eq({WRITER_KEY=>"*:percy,*:ron,*:ginny"})
      acl.is_valid?.should be_true
    end
  end

  context "grant nil" do
    it "permissions and users are set correctly" do
      acl = AclWriter.new({WRITER_KEY=>"*:ginny,*:ron"})

      acl.grant(nil).should be_true

      acl.to_hash.should eq({WRITER_KEY=>"*:ginny,*:ron"})
      acl.is_valid?.should be_true
    end
  end
end
