require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "list command" do
  before(:all) do
    cptr("remove -f syncfrom")
    cptr("remove -f syncto")
    cptr("remove -f syncb")
    cptr("containers:add syncfrom")
    cptr("containers:add syncto")
    cptr("containers:add syncb -z region-b.geo-1")
    cptr("copy spec/fixtures/files/Matryoshka/Putin/Yeltsin :syncfrom")
  end

  context "containers:sync" do
    it "should report success" do
      rsp = cptr("location :syncto")
      location = rsp.stdout.strip

      rsp = cptr("containers:sync :syncto keyo")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Container :syncto using key 'keyo'\n")
      rsp.exit_status.should be_exit(:success)

      rsp = cptr("containers:sync :syncfrom keyo #{location}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Container :syncfrom using key 'keyo' to #{location}\n")
      rsp.exit_status.should be_exit(:success)

      rsp = cptr("list -c sname,synckey,syncto -d --sync")
      rsp.stderr.should eq("")
      rsp.stdout.should include("syncfrom,keyo,#{location}\n")
      rsp.stdout.should include("syncto,keyo,\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "containers:sync -z region-b.geo-1" do
    it "should report success" do
      rsp = cptr("location :syncb -z region-b.geo-1")
      location = rsp.stdout.strip

      rsp = cptr("containers:sync :syncb keyo -z region-b.geo-1")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Container :syncb using key 'keyo'\n")
      rsp.exit_status.should be_exit(:success)

      rsp = cptr("containers:sync :syncto keyo #{location}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Container :syncto using key 'keyo' to #{location}\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "containers:sync :bogus keyo" do
    it "should report failure" do
      rsp = cptr("containers:sync :bogus keyo")

      rsp.stderr.should eq("Cannot find container ':bogus'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "containers:sync :syncto keyo -z region-a.geo-1" do
    it "should report success" do
      rsp = cptr("containers:sync :syncto keyo -z region-a.geo-1")
      rsp.stderr.should eq("")
      rsp.stdout.should eq("Container :syncto using key 'keyo'\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "containers:sync :syncto keyo -z bogus" do
    it "should report error" do
      rsp = cptr("containers:sync :syncto keyo -z bogus")
      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("containers:sync :syncto keyo -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      path = File.expand_path(File.dirname(__FILE__) + '/../../../..')
      rsp.stderr.should eq("Error syncing container: Could not find account file: #{path}/spec/tmp/home/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:each) {reset_all()}
  end

  after(:all) do
    cptr("remove -f syncfrom")
#    cptr("remove -f syncto")
#    cptr("remove -f syncb")
  end
end
