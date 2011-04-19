require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Get command" do
  
  before(:all) do
    @kvs = storage_connection
  end
  
  context "getting an object from a bucket" do

    before(:all) do
      @kvs.put_bucket('get_bucket')
      @kvs.put_object('get_bucket', 'highly_unusual_file_name.txt', read_file('foo.txt'))
    end

    context "when object does not exist" do
      it "should exit with object not found" do
        response = capture(:stderr){ HP::Scalene::CLI.start(['get', ':get_bucket/nonexistant.txt']) }
        response.should eql("The specified object does not exist.\n")
      end
    end
    
    context "when bucket does not exist" do
      it "should exit with bucket not found" do
        response = capture(:stderr){ HP::Scalene::CLI.start(['get', ':nonexistant_bucket/foo.txt']) }
        response.should eql("You don't have a bucket 'nonexistant_bucket'.\n")
      end
    end

    context "when syntax is not correct" do
      it "should exit with message about bad syntax" do
        response = capture(:stderr){ HP::Scalene::CLI.start(['get', '/foo/foo']) }
        response.should eql("The object path '/foo/foo' wasn't recognized.  Usage: 'scalene get :bucket_name/object_name'.\n")
      end
    end

    context "when object and bucket exist" do
      
      before(:all) do
        @response = capture(:stdout){ HP::Scalene::CLI.start(['get', ':get_bucket/highly_unusual_file_name.txt']) }
      end
      
      it "should report success" do
        @response.should eql("Copied :get_bucket/highly_unusual_file_name.txt => ./highly_unusual_file_name.txt\n")
      end
      
      it "should have created a file" do
        File.exist?('highly_unusual_file_name.txt').should be_true
      end

      after(:all) do
        File.unlink('highly_unusual_file_name.txt')
      end
      
    end

   after(:all) do
     purge_bucket('get_bucket')
   end

  end

  
end