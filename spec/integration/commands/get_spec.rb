require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Get command" do
  
  before(:all) do
    @hp_svc = storage_connection
    @hp_svc.put_container('get_container')
    @hp_svc.put_object('get_container', 'highly_unusual_file_name.txt', read_file('foo.txt'))
    @hp_svc.put_object('get_container', 'folder/highly_unusual_file_name.txt', read_file('foo.txt'))
  end

  context "when object does not exist" do
    it "should exit with object not found" do
      response, exit_status = capture_with_status(:stderr){ HP::Scalene::CLI.start(['get', ':get_container/nonexistant.txt']) }
      response.should eql("The specified object does not exist.\n")
      exit_status.should be_exit(:not_found)
    end
  end
  
  context "when container does not exist" do
    it "should exit with container not found" do
      response, exit_status = capture_with_status(:stderr){ HP::Scalene::CLI.start(['get', ':nonexistant_container/foo.txt']) }
      response.should eql("You don't have a container 'nonexistant_container'.\n")
      exit_status.should be_exit(:not_found)
    end
  end

  context "when syntax is not correct" do
    it "should exit with message about bad syntax" do
      response, exit_status = capture_with_status(:stderr){ HP::Scalene::CLI.start(['get', '/foo/foo']) }
      response.should eql("The object path '/foo/foo' wasn't recognized.  Usage: 'scalene get :container_name/object_name'.\n")
      exit_status.should be_exit(:incorrect_usage)
    end
  end

  context "when object and container exist and object is at container level" do
    before(:all) do
      @response, @exit_status = capture_with_status(:stdout){ HP::Scalene::CLI.start(['get', ':get_container/highly_unusual_file_name.txt']) }
    end

    it "should report success" do
      @response.should eql("Copied :get_container/highly_unusual_file_name.txt => highly_unusual_file_name.txt\n")
      @exit_status.should be_exit(:success)
    end

    it "should have created a file" do
      File.exist?('highly_unusual_file_name.txt').should be_true
    end

    after(:all) do
      File.unlink('highly_unusual_file_name.txt')
    end
  end

  context "when object and container exist and object is in a nested folder" do
    before(:all) do
      @response, @exit_status = capture_with_status(:stdout){ HP::Scalene::CLI.start(['get', ':get_container/folder/highly_unusual_file_name.txt']) }
    end

    it "should report success" do
      @response.should eql("Copied :get_container/folder/highly_unusual_file_name.txt => highly_unusual_file_name.txt\n")
      @exit_status.should be_exit(:success)
    end

    it "should have created a file" do
      File.exist?('highly_unusual_file_name.txt').should be_true
    end

    after(:all) do
      File.unlink('highly_unusual_file_name.txt')
    end
  end

  after(:all) { purge_container('get_container') }
  
end