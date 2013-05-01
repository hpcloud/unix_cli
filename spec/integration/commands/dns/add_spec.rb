require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "dns:add command" do
  context "when creating dns with name description" do
    it "should show success message" do
      @dns_ttl = '7201'
      @dns_email = 'clitestadd@example.com'
      @dns_name = "cliadd1.com."
      cptr("dns:remove #{@dns_name}")

      rsp = cptr("dns:add #{@dns_name} #{@dns_email} -t #{@dns_ttl}")

      rsp.stderr.should eq("")
      @new_dns_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created dns '#{@dns_name}' with id '#{@new_dns_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr("dns -c name,ttl,email -d X #{@dns_name}")
      rsp.stdout.should eq("#{@dns_name}X#{@dns_ttl}X#{@dns_email}\n")
    end

    after(:each) do
      cptr("dns:remove #{@dns_name}")
    end
  end

  context "when creating dns with a name that already exists" do
    it "should fail" do
      @dns_email = 'clitestadd@example.com'
      @dns_name = "cliadd2.com."

      cptr("dns:add #{@dns_name} #{@dns_email}")

      rsp = cptr("dns:add #{@dns_name} #{@dns_email}")

      rsp.stderr.should eq("Dns with the name '#{@dns_name}' already exists\n")
      rsp.exit_status.should be_exit(:general_error)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("dns:add dsler email@example.com -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
