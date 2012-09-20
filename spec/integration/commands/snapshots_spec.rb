require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Snapshots command" do
  def then_expected_table(response)
    response.should match("| .*id.*|.*name.*|.*size.*|.*type.*|.*created.*|.*status.*|.*description.*|.*servers.*|\n")
    response.should match("| #{@snap1.name} *| 1 *| *|")
    response.should match("| #{@snap2.name} *| 1 *| *|")
  end

  before(:all) do
    @snap1 = VolumeTestHelper.create("cli_test_snap1")
    @snap2= VolumeTestHelper.create("cli_test_snap2")
  end

  describe "with avl settings from config" do
    context "snapshots" do
      it "should report success" do
        rsp = cptr("snapshots #{@snap1.name} #{@snap2.name}")

        rsp.stderr.should eq("")
        then_expected_table(rsp.stdout)
        rsp.exit_status.should be_exit(:success)
      end
    end

    context "snapshots:list" do
      it "should report success" do
        rsp = cptr("snapshots:list #{@snap1.name} #{@snap2.name}")

        rsp.stderr.should eq("")
        then_expected_table(rsp.stdout)
        rsp.exit_status.should be_exit(:success)
      end
    end
  end

  context "snapshots with valid avl" do
    it "should report success" do
      rsp = cptr("snapshots #{@snap1.name} #{@snap2.name} -z az-1.region-a.geo-1")

      rsp.stderr.should eq("")
      then_expected_table(rsp.stdout)
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "snapshots with invalid avl" do
    it "should report error" do
      rsp = cptr('snapshots -z blah')

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'BlockStorage' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("snapshots -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
