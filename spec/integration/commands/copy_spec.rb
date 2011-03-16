require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Copy command" do
  
  before(:all) do
    @kvs = storage_connection
  end
  
  context "copying local file to bucket" do
    
    before(:all) { purge_bucket('my_bucket') }
    
    context "when local file does not exist" do
      it "should exit with file not found" do
        response = capture(:stdout){ HPCloud::CLI.start(['copy', 'foo.txt', ':my_bucket']) }
        response.should eql("File not found at 'foo.txt'.\n")
      end
    end
    
    context "when bucket does not exist" do
      it "should exit with bucket not found" do
        response = capture(:stdout){ HPCloud::CLI.start(['copy', 'spec/fixtures/files/foo.txt', ':my_bucket']) }
        response.should eql("You don't have a bucket 'my_bucket'.\n")
      end
    end
    
    context "when file and bucket exist" do
      before(:all) do
        @kvs.put_bucket('my_bucket')
        @response = capture(:stdout){ HPCloud::CLI.start(['copy', 'spec/fixtures/files/foo.txt', ':my_bucket']) }
        @get = @kvs.get_object('my_bucket', 'foo.txt')
      end
      
      it "should report success" do
        @response.should eql("Copied spec/fixtures/files/foo.txt => :my_bucket/foo.txt\n")
      end
      
      it "should copy file to bucket" do
        @get.status.should eql(200)
      end
      
      it "should preserve content-type" do
        @get.headers["content-type"].should eql('text/plain')
      end
      
      after(:all) { purge_bucket('my_bucket') }
    end
    
  end
  
end