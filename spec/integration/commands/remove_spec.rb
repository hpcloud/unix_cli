require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "#remove command" do
  
  before(:all) do
    @kvs = storage_connection
  end
  
  context "removing an object from bucket" do
    
    before(:all) { create_bucket_with_files('my_bucket', 'foo.txt') }
    
    context "when object does not exist" do
      it "should exit with object not found" do
        response = capture(:stderr){ HPCloud::CLI.start(['remove', ':my_bucket/nonexistant.txt']) }
        response.should eql("You don't have a object named 'nonexistant.txt'.\n")
      end
    end
    
    context "when bucket does not exist" do
      it "should exit with bucket not found" do
        response = capture(:stderr){ HPCloud::CLI.start(['remove', ':nonexistant_bucket']) }
        response.should eql("You don't have a bucket named 'nonexistant_bucket'\n")
      end
    end
    
    context "when object and bucket exist" do
      before(:all) do
#        @kvs.put_bucket('my_bucket')
#        @response = capture(:stdout){ HPCloud::CLI.start(['copy', 'spec/fixtures/files/foo.txt', ':my_bucket']) }
#        @get = @kvs.get_object('my_bucket', 'foo.txt')
      end
      
      it "should report success" do
#        @response.should eql("Copied spec/fixtures/files/foo.txt => :my_bucket/foo.txt\n")
        response = capture(:stderr){ HPCloud::CLI.start(['remove', ':my_bucket/foo.txt']) }
        response.should eql("\n")
      end
      

      after(:all) { purge_bucket('my_bucket') }
    end
    
  end
  
  pending "copying remote object to local filesystem" do

  end
  
end