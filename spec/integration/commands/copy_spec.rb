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
  
  context "copying remote object to local filesystem" do
    
    before(:all) { create_bucket_with_files('copy_remote_to_local', 'foo.txt') }
    
    context "when bucket does not exist" do
      it "should exit with bucket not found" do
        response = capture(:stdout){ HPCloud::CLI.start(['copy', ':copy_blah/foo.txt', '/tmp/foo.txt']) }
        response.should eql("You don't have a bucket 'copy_blah'.\n")
      end
    end
    
    context "when object does not exist" do
      it "should exit with object not found" do
        response = capture(:stdout){ HPCloud::CLI.start(['copy', ':copy_remote_to_local/foo2.txt', '/tmp/foo.txt']) }
        response.should eql("The specified object does not exist.\n")
      end 
    end
    
    context "when local directory structure does not exist" do
      it "should exit with directory not present" do
        response = capture(:stdout){ HPCloud::CLI.start(['copy', ':copy_remote_to_local/foo.txt', '/blah/foo.txt']) }
        response.should eql("No directory exists at '/blah'.\n")
      end
    end
    
    context "when local directory and object exist" do
      before(:all) do
        @response = capture(:stdout){ HPCloud::CLI.start(['copy', ':copy_remote_to_local/foo.txt', 'spec/tmp/foo.txt']) }
      end
      
      it "should describe copy" do
        @response.should eql("Copied :copy_remote_to_local/foo.txt => spec/tmp/foo.txt\n")
      end
      
      it "should create local file" do
        should satisfy { File.exists?('spec/tmp/foo.txt') }
      end
      
      it "should have same body as object" do
        get = @kvs.get_object('copy_remote_to_local', 'foo.txt')
        File.read('spec/tmp/foo.txt').should eql(get.body)
      end
    end
    
    pending 'when cannot write file'
    
    after(:all) { purge_bucket('copy_remote_to_local') }
    
  end
  
  context "copying remote object within a bucket" do
    
    before(:all) do
      #create_bucket_with_files('copy_inside_bucket', 'foo.txt')
      @kvs.put_bucket('copy_inside_bucket')
      @kvs.put_object('copy_inside_bucket', 'foo.txt', read_file('foo.txt'), {'Content-Type' => 'text/plain'})
    end
    
    context "when bucket does not exist" do
      it "should exit with bucket not found" do
        response = capture(:stdout){ HPCloud::CLI.start(['copy', ':missing_bucket/foo.txt', ':missing_bucket/tmp/foo.txt']) }
        response.should eql("You don't have a bucket 'missing_bucket'.\n")
      end
    end
    
    context "when object does not exist" do
      it "should exit with object not found" do
        response = capture(:stdout){ HPCloud::CLI.start(['copy', ':copy_inside_bucket/missing.txt', ':copy_inside_bucket/tmp/missing.txt']) }
        response.should eql("The specified object does not exist.\n")
      end
    end
    
    context "when bucket and object exist" do
      before(:all) do
        @response = capture(:stdout){ HPCloud::CLI.start(['copy', ':copy_inside_bucket/foo.txt', ':copy_inside_bucket/new/foo.txt']) }
        @get = @kvs.get_object('copy_inside_bucket', 'new/foo.txt')
      end
      
      it "should exit with object copied" do
        @response.should eql("Copied :copy_inside_bucket/foo.txt => :copy_inside_bucket/new/foo.txt\n")
      end
      
      it "should create new object" do
        @get.status.should eql(200)
      end
      
      it "should preserve content-type" do
        @get.headers['content-type'].should eql('text/plain')
      end

      it "should have same object body" do
        @get.body.should eql(read_file('foo.txt'))
      end
    end
    
    pending "when new object cannot be written" do  
    end
    
    after(:all) { purge_bucket('copy_inside_bucket') }
    
  end
  
  pending "copying a remote object to another bucket" do
  end
  
end