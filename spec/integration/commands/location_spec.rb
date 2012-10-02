require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'location command' do

  before(:all) do
    @hp_svc = storage_connection
    cptr("container:add -a secondary :someone_elses")
    @hp_svc.put_container('my_location_container')
    @hp_svc.put_object('my_location_container', 'tiny.txt', read_file('foo.txt'))
  end

  context "run on missing container" do
    it "should show fail message" do
      rsp = cptr('location :my_missing_container')

      rsp.stderr.should eq("Cannot find container ':my_missing_container'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "run on missing object" do
    it "should show fail message" do
      @hp_svc.put_container('my_empty_container')

      rsp = cptr('location :my_empty_container/file')

      rsp.stderr.should eq("Cannot find object named ':my_empty_container/file'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end

    after(:all) { purge_container('my_empty_container') }
  end

  context "run without permission for container" do
    it "should display error message" do
      rsp = cptr('location :someone_elses')

      rsp.stderr.should eq("Cannot find container ':someone_elses'.\n")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "run without permissions for object" do
    it "should display error message" do
      @file_name='spec/fixtures/files/Matryoshka/Putin/Medvedev.txt'
      cptr("copy -a secondary #{@file_name} :someone_elses")

      rsp = cptr("location :someone_elses/#{@file_name}")

      rsp.stderr.should eq("Cannot find container ':someone_elses'.\n")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "with avl settings from config" do
    it "should return location" do
      @hp_svc.put_container('my_location_container')

      rsp = cptr('location :my_location_container')

      rsp.stderr.should eq("")
      rsp.stdout.should eq("#{@hp_svc.url}/my_location_container\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "location for container with valid avl" do
    it "should report success" do
      rsp = cptr('location :my_location_container -z region-a.geo-1')

      rsp.stderr.should eq("")
      rsp.stdout.should eq("#{@hp_svc.url}/my_location_container\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "location for container with invalid avl" do
    it "should report error" do
      rsp = cptr('location :my_location_container -z blah')

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end



  context "with avl settings from config" do
    it "should return location" do
      rsp = cptr('location :my_location_container/tiny.txt')

      rsp.stderr.should eq("")
      rsp.stdout.should eq("#{@hp_svc.url}/my_location_container/tiny.txt\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "location for file with valid avl" do
    it "should report success" do
      rsp = cptr('location :my_location_container/tiny.txt -z region-a.geo-1')

      rsp.stderr.should eq("")
      rsp.stdout.should eq("#{@hp_svc.url}/my_location_container/tiny.txt\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "location for file with invalid avl" do
    it "should report error" do
      rsp = cptr('location :my_location_container/tiny.txt -z blah')

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("location :my_location_container/tiny.txt -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end

  after(:all) { purge_container('my_location_container') }
end
