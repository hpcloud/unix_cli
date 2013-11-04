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

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "servers:add command" do
  before(:all) do
    @sg_name = 'cli_test_sg1'
    @keypair_name = 'cli_test_key1'
    SecurityGroupTestHelper.create(@sg_name)
    KeypairTestHelper.create(@keypair_name)
  end

  context "when creating server with name nearly nothing" do
    it "should show success message" do
      @server_name = resource_name("add0")

      rsp = cptr("servers:add #{@server_name} -k #{@keypair_name}")

      rsp.stderr.should eq("")
      @new_server_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created server '#{@server_name}' with id '#{@new_server_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      server = Servers.new.get(@server_name)
      server.is_valid?.should be_true
      server.flavor.should eq("#{AccountsHelper.get_flavor_id()}")
      server.image.should eq("#{AccountsHelper.get_image_id()}")
      @keyfile =KeypairHelper.private_filename("#{@new_server_id}")
      File.exists?(@keyfile).should be_true
    end

    after(:each) do
      cptr("servers:remove #{@server_name}")
      FileUtils.rm_f(@keyfile) unless @keyfile.nil?
    end
  end

  context "when creating server with name, image and flavor (no security group)" do
    it "should show success message" do
      @server_name = resource_name("add1")

      rsp = cptr("servers:add #{@server_name} #{AccountsHelper.get_flavor_id()} -i #{AccountsHelper.get_image_id()} -k #{@keypair_name}")

      rsp.stderr.should eq("")
      @new_server_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created server '#{@server_name}' with id '#{@new_server_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr("servers -c id,name -d X #{@server_name}")
      rsp.stdout.should eq("#{@new_server_id}X#{@server_name}\n")
    end

    after(:each) do
      cptr("servers:remove #{@server_name}")
    end
  end

  context "when creating server with name, image, flavor, keyname and security group and metadata" do
    it "should show success message" do
      @server_name = resource_name("add2")

      rsp = cptr("servers:add #{@server_name} #{AccountsHelper.get_flavor_id()} -i #{AccountsHelper.get_image_id()} -k #{@keypair_name} -s #{@sg_name} -m E=mc2,PV=nRT")

      rsp.stderr.should eq("")
      @new_server_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created server '#{@server_name}' with id '#{@new_server_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr("servers -c id,name -d X #{@server_name}")
      rsp.stdout.should eq("#{@new_server_id}X#{@server_name}\n")
      srvr = HP::Cloud::Servers.new.get([@new_server_id])
      srvr.length.should eq(1)
      srvr[0].meta.hsh['E'].should eq('mc2')
      srvr[0].meta.hsh['PV'].should eq('nRT')
    end

    after(:each) do
      cptr("servers:remove #{@server_name}")
    end
  end

  context "when creating server with name, image, flavor, keypair and only security group" do
    it "should show success message" do
      @server_name = resource_name("add4")

      rsp = cptr("servers:add #{@server_name} #{AccountsHelper.get_flavor_id()}  -i #{AccountsHelper.get_image_id()} -k #{@keypair_name} -s #{@sg_name}")

      rsp.stderr.should eq("")
      @new_server_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created server '#{@server_name}' with id '#{@new_server_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr("servers -c id,name -d X #{@server_name}")
      rsp.stdout.should eq("#{@new_server_id}X#{@server_name}\n")
    end

    after(:each) do
      cptr("servers:remove #{@server_name}")
    end
  end

  context "when creating windows image server" do
    it "should show success message" do
      @server_name = resource_name("add5")
      @pem_file = ENV['HOME'] + "/.hpcloud/keypairs/cli_test_key1.pem"

      rsp = cptr("servers:add #{@server_name} #{AccountsHelper.get_flavor_id()} -i #{AccountsHelper.get_win_image_id()} -k #{@keypair_name} -p #{@pem_file}")

      rsp.stderr.should eq("")
      @new_server_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should include("Created server '#{@server_name}' with id '#{@new_server_id}'.\nRetrieving password, this may take several minutes...\nWindows password: ")
      # If this fails at this point, the password did not decode.
      # Try to remove the keypair, the keypair probably does not match
      rsp.exit_status.should be_exit(:success)
      rsp = cptr("servers -c id,name -d X #{@server_name}")
      rsp.stdout.should eq("#{@new_server_id}X#{@server_name}\n")
      @keyfile =KeypairHelper.private_filename("#{@new_server_id}")
      File.exists?(@keyfile).should be_true
    end

    after(:each) do
      cptr("servers:remove #{@server_name}")
      FileUtils.rm_f(@keyfile) unless @keyfile.nil?
    end
  end

  context "when creating windows image server without -p option" do
    it "should show success message" do
      @server_name = resource_name("add5")

      rsp = cptr("servers:add #{@server_name} #{AccountsHelper.get_flavor_id()} -i #{AccountsHelper.get_win_image_id()} -k #{@keypair_name}")

      rsp.stderr.should eq("")
      @new_server_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should include("Created server '#{@server_name}' with id '#{@new_server_id}'.\nRetrieving password, this may take several minutes...\nWindows password: ")
      # If this fails at this point, the password did not decode.
      # Try to remove the keypair, the keypair probably does not match
      rsp.exit_status.should be_exit(:success)
      rsp = cptr("servers -c id,name -d X #{@server_name}")
      rsp.stdout.should eq("#{@new_server_id}X#{@server_name}\n")
    end

    after(:each) do
      cptr("servers:remove #{@server_name}")
    end
  end

  context "when creating windows image server with bogus pem" do
    it "should show failure message" do
      @server_name = resource_name("add5")

      rsp = cptr("servers:add #{@server_name} #{AccountsHelper.get_flavor_id()} -i #{AccountsHelper.get_win_image_id()} -k #{@keypair_name} -p bogus.pem")

      path = File.expand_path(File.dirname(__FILE__) + '/../../../..')
      rsp.stderr.should eq("Error reading private key file 'bogus.pem': No such file or directory - #{path}/bogus.pem\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:incorrect_usage)
    end
  end

  context "when creating windows image server with no pem" do
    it "should show failure message" do
      @server_name = resource_name("add5")
      filename = KeypairHelper.private_filename("cli_test_key2")
      FileUtils.rm_f(filename)

      rsp = cptr("servers:add #{@server_name} #{AccountsHelper.get_flavor_id()} -i #{AccountsHelper.get_win_image_id()} -k cli_test_key2")

      rsp.stderr.should eq("You must specify the private key file if you want to create a windows instance.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:incorrect_usage)
    end
  end

  context "when creating server with a name that already exists" do
    before(:all) do
      ServerTestHelper.create("cli_test_srv1")

      rsp = cptr("servers:add #{@server_name} #{AccountsHelper.get_flavor_id()} -i #{AccountsHelper.get_image_id()} -k #{@keypair_name}")

      rsp.stderr.should eq("Server with the name '#{@server_name}' already exists\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
  end

  context "servers:add with valid avl" do
    it "should report success" do
      @server_name = resource_name("add5")

      rsp = cptr("servers:add #{@server_name} #{AccountsHelper.get_flavor_id()} -i #{AccountsHelper.get_image_id()} -k #{@keypair_name} -z region-b.geo-1")

      rsp.stderr.should eq("")
      @server_id2 = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created server '#{@server_name}' with id '#{@server_id2}'.\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr("servers -c id,name -d X #{@server_name}")
      rsp.stdout.should eq("#{@new_server_id}X#{@server_name}\n")
    end

    after(:each) do
      cptr("servers:remove #{@server_name}")
    end
  end

  context "when creating server from a volume" do
    it "should show success message" do
      @volume_name = resource_name("volumau5")
      rsp = cptr("volumes:add #{@volume_name} 10 -i #{AccountsHelper.get_image_id()}")
      rsp.stderr.should eq("")
      @server_name = resource_name("add6")

      rsp = cptr("servers:add #{@server_name} #{AccountsHelper.get_flavor_id()} -i #{AccountsHelper.get_image_id()} -v #{@volume_name} -k #{@keypair_name}")

      rsp.stderr.should eq("")
      @new_server_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created server '#{@server_name}' with id '#{@new_server_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr("servers -c id,name -d X #{@server_name}")
      rsp.stdout.should eq("#{@new_server_id}X#{@server_name}\n")
    end

    after(:each) do
      cptr("servers:remove #{@server_name}")
      cptr("volumes:remove #{@volume_name}")
    end
  end

  context "when creating server from a bogus volume" do
    it "should report error" do
      @server_name = resource_name("add7")

      rsp = cptr("servers:add #{@server_name} #{AccountsHelper.get_flavor_id()} -v bogus -k #{@keypair_name}")

      rsp.stderr.should eq("Cannot find a volume matching 'bogus'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end

    after(:each) do
      cptr("servers:remove #{@server_name}")
      cptr("volumes:remove #{@volume_name}")
    end
  end

  context "servers:add with invalid avl" do
    it "should report error" do
      rsp = cptr("servers:add other_name #{AccountsHelper.get_flavor_id()} -i #{AccountsHelper.get_image_id()} -k #{@keypair_name} -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { HP::Cloud::Connection.instance.clear_options() }
  end

  context "verify the -k option is mandatory" do
    it "should report error" do
      rsp = cptr("servers:add other_name #{AccountsHelper.get_flavor_id()} -i #{AccountsHelper.get_image_id()}")

      rsp.stderr.should eq("No value provided for required options '--key-name'\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("servers:add other_name #{AccountsHelper.get_flavor_id()} -i #{AccountsHelper.get_image_id()} -k #{@keypair_name} -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end

  after(:all) do
    @keypair.destroy if @keypair
  end
end
