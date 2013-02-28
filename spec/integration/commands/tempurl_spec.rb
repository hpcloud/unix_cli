require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'tempurl command' do

  before(:all) do
    @hp_svc = storage_connection
    rsp = cptr("containers:add -a secondary :someoneelses")
    rsp = cptr("containers:add :tempcontainer")
    file = File.expand_path(File.dirname(__FILE__) + '/../../fixtures/files/foo.txt')
    rsp = cptr("copy #{file} :tempcontainer")
  end

  context "run on missing container" do
    it "should show fail message" do
      rsp = cptr('tempurl :my_missing_container/foo.txt')

      rsp.stderr.should eq("Cannot find container ':my_missing_container'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "run on local file" do
    it "should show fail message" do
      rsp = cptr("tempurl #{__FILE__}")

      rsp.stderr.should eq("Temporary URLs of local objects is not supported: #{__FILE__}\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:incorrect_usage)
    end
  end

  context "run on missing object" do
    it "should show fail message" do
      cptr("containers:add :empty")

      rsp = cptr('tempurl :empty/file')

      rsp.stderr.should eq("Cannot find object ':empty/file'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end

    after(:all) { purge_container('empty') }
  end

  context "run without permissions for object" do
    it "should display error message" do
      @file_name='spec/fixtures/files/Matryoshka/Putin/Medvedev.txt'
      cptr("copy -a secondary #{@file_name} :someoneelses")

      rsp = cptr("tempurl :someoneelses/#{@file_name}")

      rsp.stderr.should eq("Cannot find object ':someoneelses/spec/fixtures/files/Matryoshka/Putin/Medvedev.txt'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "with avl settings from config" do
    it "should return tempurl" do
      rsp = cptr('tempurl :tempcontainer/foo.txt')

      rsp.stderr.should eq("")
      rsp.stdout.should include("#{@hp_svc.url}")
      rsp.stdout.should include("/tempcontainer/foo.txt")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "tempurl for file with valid avl" do
    it "should report success" do
      rsp = cptr('tempurl :tempcontainer/foo.txt -z region-a.geo-1')

      rsp.stderr.should eq("")
      rsp.stdout.should include("#{@hp_svc.url}")
      rsp.stdout.should include("/tempcontainer/foo.txt")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "tempurl for file with invalid avl" do
    it "should report error" do
      rsp = cptr('tempurl :tempcontainer/foo.txt -z blah')

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("tempurl :tempcontainer/foo.txt -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end

  after(:all) { purge_container('tempcontainer') }
end
