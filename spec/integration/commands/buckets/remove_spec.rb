require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "buckets:remove command" do

  before(:all) do
    @kvs = storage_connection
    @other_user = storage_connection(:secondary)
  end

  context "when bucket does not exist" do
    
    before(:all) do
      @response, @exit_status = run_command('buckets:remove :my_nonexistant_bucket').stderr_and_exit_status
    end
    
    it "should show error message" do
      @response.should eql("You don't have a bucket named 'my_nonexistant_bucket'.\n")
    end
    
    it "should have failed exit status" do
      @exit_status.should be_exit(:not_found)
    end
    
  end
  
  context "when user doesn't have permissions to remove" do
    
    before(:all) do
      @other_user.put_bucket('other_users_bucket')
      @response, @exit_status = run_command('buckets:remove :other_users_bucket').stderr_and_exit_status
    end
    
    it "should show error message" do
      @response.should eql("Access Denied.\n")
    end
    
    it "should exit with denied status" do
      @exit_status.should be_exit(:permission_denied)
    end
    
    after(:all) do
      purge_bucket('other_users_bucket', :connection => @other_user)
    end
    
  end
  
  context "when user owns bucket and it exists" do
    
    before(:all) do
      @kvs.put_bucket('bucket_to_remove')
      @response, @exit = run_command('buckets:remove :bucket_to_remove').stdout_and_exit_status
    end
    
    it "should show success message" do
      @response.should eql("Removed bucket 'bucket_to_remove'.\n")
    end
    
    it "should remove bucket" do
      lambda{ @kvs.get_bucket('bucket_to_remove') }.should raise_error(Excon::Errors::NotFound)
    end
    
    it "should have success exit status" do
      @exit.should be_exit(:success)
    end
    
    after(:all) { purge_bucket('bucket_to_remove') }
    
  end

end