require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Get command," do
  
  before(:all) do
    @kvs = storage_connection
  end
  
  context "getting an object from a bucket" do

    before(:all) do
      purge_bucket('my_bucket')
      create_bucket_with_files('my_bucket', 'foo.txt')
    end

    context "when object does not exist" do
      it "should exit with object not found" do
        response = capture(:stderr){ HPCloud::CLI.start(['get', ':my_bucket/nonexistant.txt']) }
        response.should eql("The specified object does not exist.\n")
      end
    end
    
    context "when bucket does not exist" do
      it "should exit with bucket not found" do
        response = capture(:stderr){ HPCloud::CLI.start(['get', ':nonexistant_bucket/foo.txt']) }
        response.should eql("You don't have a bucket 'nonexistant_bucket'.\n")
      end
    end

    context "when syntax is not correct" do
      it "should exit with message about bad syntax" do
        response = capture(:stderr){ HPCloud::CLI.start(['get', '/foo/foo']) }
        response.should eql("The object path '/foo/foo' wasn't recognized.  Usage: 'hpcloud get :bucket_name/object_name'.\n")
      end
    end

    context "when object and bucket exist" do
      before(:all) do
      end
      it "should report success" do
        response = capture(:stdout){ HPCloud::CLI.start(['get', ':my_bucket/foo.txt']) }
        response.should eql("Copied :my_bucket/foo.txt => ./foo.txt\n")
        File.exist?('./foo.txt').should eql true
      end
#      after(:all) { remove_file './getfoo.txt' }
    end


    after(:all) do
    end

  end

  
end