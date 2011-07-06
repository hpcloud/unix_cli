require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'location command' do
#
#  before(:all) do
#    @kvs = storage_connection
#    @other = storage_connection(:secondary)
#  end
#
#  context "run on missing bucket" do
#
#    before(:all) do
#      @response, @exit = run_command('location :my_missing_bucket').stderr_and_exit_status
#    end
#
#    it "should show fail message" do
#      @response.should eql("No bucket named 'my_missing_bucket' exists.\n")
#    end
#    its_exit_status_should_be(:not_found)
#
#  end
#
#  context "run on missing object" do
#
#    before(:all) do
#      @kvs.put_container('my_empty_bucket')
#      @response, @exit = run_command('location :my_empty_bucket/file').stderr_and_exit_status
#    end
#
#    it "should show fail message" do
#      @response.should eql("No object exists at 'my_empty_bucket/file'.\n")
#    end
#    its_exit_status_should_be(:not_found)
#
#    after(:all) { purge_bucket('my_empty_bucket') }
#
#  end
#
#  context "run without permission for bucket" do
#
#    before(:all) do
#      @other.put_container('someone_elses')
#      @response, @exit = run_command('location :someone_elses').stderr_and_exit_status
#    end
#
#    it "should display error message" do
#      @response.should eql("Access Denied.\n")
#    end
#    its_exit_status_should_be(:permission_denied)
#
#    after(:all) { purge_bucket('someone_elses', :connection => @other) }
#  end
#
#  context "run without permissions for object" do
#
#    before(:all) do
#      @other.put_container('someone_elses')
#      #### @other.put_bucket_acl('someone_elses', 'public-read')
#      @other.put_object('someone_elses', 'foo.txt', read_file('foo.txt'))
#      @response, @exit = run_command('location :someone_elses/foo.txt').stderr_and_exit_status
#    end
#
#    it "should display error message" do
#      @response.should eql("Access Denied.\n")
#    end
#    its_exit_status_should_be(:permission_denied)
#
#    after(:all) { purge_bucket('someone_elses', :connection => @other) }
#
#  end
#
#  context "run with permissions on bucket" do
#
#    before(:all) do
#      @kvs.put_container('my_location_bucket')
#      HP::Scalene::Config.stub(:current_credentials).and_return({:api_endpoint => "endpoint.scalene.hp"})
#      @response, @exit = run_command('location :my_location_bucket').stdout_and_exit_status
#    end
#
#    it "should return location" do
#      @response.should eql("http://endpoint.scalene.hp/my_location_bucket/\n")
#    end
#    its_exit_status_should_be(:success)
#
#    after(:all) { purge_bucket('my_location_bucket') }
#
#  end
#
#  context "run with permissions on file" do
#
#    before(:all) do
#      @kvs.put_container('my_location_bucket')
#      @kvs.put_object('my_location_bucket', 'tiny.txt', read_file('foo.txt'))
#      HP::Scalene::Config.stub(:current_credentials).and_return({:api_endpoint => "endpoint.scalene.hp"})
#      @response, @exit = run_command('location :my_location_bucket/tiny.txt').stdout_and_exit_status
#    end
#
#    it "should return location" do
#      @response.should eql("http://endpoint.scalene.hp/my_location_bucket/tiny.txt\n")
#    end
#    its_exit_status_should_be(:success)
#
#    after(:all) { purge_bucket('my_location_bucket') }
#
#  end

end
