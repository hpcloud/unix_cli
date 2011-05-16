require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Copy command" do
  
  before(:all) do
    @kvs = storage_connection
  end
  
  context "copying local file to bucket" do
    before(:all) do
      purge_bucket('my_bucket')
      @kvs.put_bucket('my_bucket')
    end
    
    context "when local file does not exist" do
      it "should exit with file not found" do
        response, exit_status = capture_with_status(:stderr){ HP::Scalene::CLI.start(['copy', 'foo.txt', ':my_bucket']) }
        response.should eql("File not found at 'foo.txt'.\n")
        exit_status.should be_exit(:not_found)
      end
    end
    
    context "when local file cannot be read" do
      before(:all) do
        File.chmod(0200, 'spec/fixtures/files/cantread.txt')
      end
      
      it "should not be a readable file" do
        File.readable?('spec/fixtures/files/cantread.txt').should be_false
      end
      
      it "should show error message" do
        response, exit_status = capture_with_status(:stderr){ HP::Scalene::CLI.start(['copy', 'spec/fixtures/files/cantread.txt', ':my_bucket']) }
        response.should eql("The selected file cannot be read.\n")
        exit_status.should be_exit(:permission_denied)
      end
      
      after(:all) do
        File.chmod(0644, 'spec/fixtures/files/cantread.txt')
      end
    end
    
    context "when bucket does not exist" do
      it "should exit with bucket not found" do
        response, exit_status = capture_with_status(:stderr){ HP::Scalene::CLI.start(['copy', 'spec/fixtures/files/foo.txt', ':missing_bucket']) }
        response.should eql("You don't have a bucket 'missing_bucket'.\n")
        exit_status.should be_exit(:not_found)
      end
    end

    context "when bucket is public-read but remote file cannot be overwritten" do
      before(:all) do
        @kvs_other_user = storage_connection(:secondary)
        @kvs_other_user.put_bucket('public_read_bucket')
        @kvs_other_user.put_bucket_acl('public_read_bucket', 'public-read')
        @kvs_other_user.put_object('public_read_bucket', 'foo.txt', read_file('foo.txt'), {'Content-Type' => 'text/plain'})
      end

      it "should exit with permission denied" do
        response, exit_status = capture_with_status(:stderr){ HP::Scalene::CLI.start(['copy', 'spec/fixtures/files/foo.txt', ':public_read_bucket/foo.txt']) }
        response.should eql("Permission denied\n")
        exit_status.should be_exit(:permission_denied)
      end

      after(:all) do
        purge_bucket('public_read_bucket', {:connection => @kvs_other_user})
      end
    end
    
    context "when file and bucket exist" do
      before(:all) do
        @response, @exit_status = capture_with_status(:stdout){ HP::Scalene::CLI.start(['copy', 'spec/fixtures/files/foo.txt', ':my_bucket']) }
        @head = @kvs.head_object('my_bucket', 'foo.txt')
      end
      
      it "should report success" do
        @response.should eql("Copied spec/fixtures/files/foo.txt => :my_bucket/foo.txt\n")
        @exit_status.should be_exit(:success)
      end
      
      it "should copy file to bucket" do
        @head.status.should eql(200)
      end
      
      it "should preserve content-type" do
        @head.headers["Content-Type"].should eql('text/plain')
      end
      
    end

    context "when local file has spaces in name" do
      before(:all) do
        @response, @exit_status = capture_with_status(:stdout){ HP::Scalene::CLI.start(['copy', 'spec/fixtures/files/with space.txt', ':my_bucket']) }
        @get = @kvs.get_object('my_bucket', 'with_space.txt')
      end

      it "should report success" do
        @response.should eql("Copied spec/fixtures/files/with space.txt => :my_bucket/with_space.txt\n")
        @exit_status.should be_exit(:success)
      end

    end
    
    after(:all) { purge_bucket('my_bucket') }
  end
  
  context "copying remote object to local filesystem" do
    
    before(:all) { create_bucket_with_files('copy_remote_to_local', 'foo.txt') }
    
    context "when bucket does not exist" do
      it "should exit with bucket not found" do
        response, exit_status = capture_with_status(:stderr){ HP::Scalene::CLI.start(['copy', ':copy_blah/foo.txt', '/tmp/foo.txt']) }
        response.should eql("You don't have a bucket 'copy_blah'.\n")
        exit_status.should be_exit(:not_found)
      end
    end
    
    context "when object does not exist" do
      it "should exit with object not found" do
        response, exit_status = capture_with_status(:stderr){ HP::Scalene::CLI.start(['copy', ':copy_remote_to_local/foo2.txt', '/tmp/foo.txt']) }
        response.should eql("The specified object does not exist.\n")
        exit_status.should be_exit(:not_found)
      end 
    end
    
    context "when local directory structure does not exist" do
      it "should exit with directory not present" do
        response, exit_status = capture_with_status(:stderr){ HP::Scalene::CLI.start(['copy', ':copy_remote_to_local/foo.txt', '/blah/foo.txt']) }
        response.should eql("No directory exists at '/blah'.\n")
        exit_status.should be_exit(:not_found)
      end
    end

    context "when local directory and object exist" do
      before(:all) do
        @response, @exit_status = capture_with_status(:stdout){ HP::Scalene::CLI.start(['copy', ':copy_remote_to_local/foo.txt', 'spec/tmp/foo.txt']) }
      end
      
      it "should describe copy" do
        @response.should eql("Copied :copy_remote_to_local/foo.txt => spec/tmp/foo.txt\n")
        @exit_status.should be_exit(:success)
      end
      
      it "should create local file" do
        File.exists?('spec/tmp/foo.txt').should be_true
      end
      
      it "should have same body as object" do
        get = @kvs.get_object('copy_remote_to_local', 'foo.txt')
        File.read('spec/tmp/foo.txt').should eql(get.body)
      end

      after(:all) do
        File.unlink('spec/tmp/foo.txt')
      end

    end

    context "when target is local directory" do
      before(:all) do
        @response, @exit_status = capture_with_status(:stdout){ HP::Scalene::CLI.start(['copy', ':copy_remote_to_local/foo.txt', 'spec/tmp/']) }
      end

      it "should describe copy" do
        @response.should eql("Copied :copy_remote_to_local/foo.txt => spec/tmp/foo.txt\n")
        @exit_status.should be_exit(:success)
      end

      it "should create local file" do
        File.exists?('spec/tmp/foo.txt').should be_true
      end

      after(:all) do
        File.unlink('spec/tmp/foo.txt')
      end

    end
    
    context 'when cannot write file' do
      
      context "when location is unwritable" do
        before(:all) do
          Dir.mkdir('spec/tmp/unwriteable') unless File.directory?('spec/tmp/unwriteable')
          File.chmod(0000, 'spec/tmp/unwriteable')
          @response, @exit = capture_with_status(:stderr){ HP::Scalene::CLI.start(['copy', ':copy_remote_to_local/foo.txt', 'spec/tmp/unwriteable/']) }
        end

        it "should show failure message" do
          @response.should eql("You don't have permission to write the target file.\n")
        end

        it "should have correct exit status" do
          @exit.should be_exit(:permission_denied)
        end
      end

      context "when location does not exist" do
        
        before(:all) do
          Dir.rmdir('spec/tmp/nonexistant') if File.directory?('spec/tmp/nonexistant')
          @response, @exit = capture_with_status(:stderr){ HP::Scalene::CLI.start(['copy', ':copy_remote_to_local/foo.txt', 'spec/tmp/nonexistant/']) }
        end

        it "should show failure message" do
          @response.should eql("The target directory is invalid.\n")
        end

        it "should have correct exit status" do
          @exit.should be_exit(:permission_denied)
        end
        
      end
      
    end
    
    after(:all) do
      purge_bucket('copy_remote_to_local')
      #File.unlink('spec/tmp/foo.txt')
    end
    
  end
  
  context "copying remote object within a bucket" do
    
    before(:all) do
      #create_bucket_with_files('copy_inside_bucket', 'foo.txt')
      @kvs.put_bucket('copy_inside_bucket')
      @kvs.put_object('copy_inside_bucket', 'foo.txt', read_file('foo.txt'), {'Content-Type' => 'text/plain'})
    end
    
    context "when bucket does not exist" do
      it "should exit with bucket not found" do
        response, exit_status = capture_with_status(:stderr){ HP::Scalene::CLI.start(['copy', ':missing_bucket/foo.txt', ':missing_bucket/tmp/foo.txt']) }
        response.should eql("You don't have a bucket 'missing_bucket'.\n")
        exit_status.should be_exit(:not_found)
      end
    end
    
    context "when object does not exist" do
      it "should exit with object not found" do
        response, exit_status = capture_with_status(:stderr){ HP::Scalene::CLI.start(['copy', ':copy_inside_bucket/missing.txt', ':copy_inside_bucket/tmp/missing.txt']) }
        response.should eql("The specified object does not exist.\n")
        exit_status.should be_exit(:not_found)
      end
    end
    
    context "when bucket and object exist" do
      before(:all) do
        @response, @exit_status = capture_with_status(:stdout){ HP::Scalene::CLI.start(['copy', ':copy_inside_bucket/foo.txt', ':copy_inside_bucket/new/foo.txt']) }
        @get = @kvs.get_object('copy_inside_bucket', 'new/foo.txt')
      end
      
      it "should exit with object copied" do
        @response.should eql("Copied :copy_inside_bucket/foo.txt => :copy_inside_bucket/new/foo.txt\n")
        @exit_status.should be_exit(:success)
      end
      
      it "should create new object" do
        @get.status.should eql(200)
      end
      
      it "should preserve content-type" do
        @get.headers['Content-Type'].should eql('text/plain')
      end

      it "should have same object body" do
        @get.body.should eql(read_file('foo.txt'))
      end
    end
    
    context "when target not absolutely specified" do
      
      before(:all) { @kvs.put_object('copy_inside_bucket', 'nested/file.txt', read_file('foo.txt'), {'Content-Type' => 'text/plain'}) }
      
      context "when bucket only" do
        it "should show success message" do
          response, exit_status = capture_with_status(:stdout){ HP::Scalene::CLI.start(['copy', ':copy_inside_bucket/nested/file.txt', ':copy_inside_bucket']) }
          response.should eql("Copied :copy_inside_bucket/nested/file.txt => :copy_inside_bucket/file.txt\n")
          exit_status.should be_exit(:success)
        end
      end
      
      context "when directory in bucket" do
        it "should show success message" do
          response, exit_status = capture_with_status(:stdout){ HP::Scalene::CLI.start(['copy', ':copy_inside_bucket/nested/file.txt', ':copy_inside_bucket/nested_new/file.txt']) }
          response.should eql("Copied :copy_inside_bucket/nested/file.txt => :copy_inside_bucket/nested_new/file.txt\n")
          exit_status.should be_exit(:success)
        end
      end
      
    end
    
    pending "when new object cannot be written" do  
    end
    
    after(:all) { purge_bucket('copy_inside_bucket') }
    
  end
  
  pending "copying a remote object to another bucket" do
    
    before(:all) do
      #create_bucket_with_files('copy_inside_bucket', 'foo.txt')
      @kvs.put_bucket('copy_between_one')
      @kvs.put_object('copy_between_one', 'foo.txt', read_file('foo.txt'), {'Content-Type' => 'text/plain'})
      @kvs.put_bucket('copy_between_two')
    end
    
    context "when bucket does not exist" do
      it "should exit with bucket not found" do
        response, exit_status = capture_with_status(:stderr){ HP::Scalene::CLI.start(['copy', ':missing_bucket/foo.txt', ':copy_between_two/tmp/foo.txt']) }
        response.should eql("You don't have a bucket 'missing_bucket'.\n")
        exit_status.should be_exit(:not_found)
      end
    end
    
    context "when object does not exist" do
      it "should exit with object not found" do
        response, exit_status = capture_with_status(:stderr){ HP::Scalene::CLI.start(['copy', ':copy_between_one/missing.txt', ':copy_between_two/tmp/missing.txt']) }
        response.should eql("The specified object does not exist.\n")
        exit_status.should be_exit(:not_found)
      end
    end
    
    context "when new bucket does not exist" do
      it "should exit with object not found" do
        response, exit_status = capture_with_status(:stderr){ HP::Scalene::CLI.start(['copy', ':copy_between_one/missing.txt', ':missing_bucket/tmp/missing.txt']) }
        response.should eql("You don't have a bucket 'missing_bucket'.\n")
        exit_status.should be_exit(:not_found)
      end
    end
    
    pending "when target is not absolutely specified" do
      
      # context "when target is bucket" do
      #   it "should give success message" do
      #     response = capture(:stdout){ HP::Scalene::CLI.start(['copy', ':copy_between_one/foo.txt', ':copy_between_two']) }
      #     response.should eql("Copied: \n")
      #   end
      # end
      
      context "when target is directory on bucket" do
        
      end
      
    end
    
    context "when object is copied successfully" do
      before(:all) do
        @response, @exit_status = capture_with_status(:stdout){ HP::Scalene::CLI.start(['copy', ':copy_between_one/foo.txt', ':copy_between_two/new/foo.txt']) }
        @get = @kvs.get_object('copy_between_two', 'new/foo.txt')
      end
      
      it "should exit with object copied" do
        @response.should eql("Copied :copy_between_one/foo.txt => :copy_between_two/new/foo.txt\n")
        @exit_status.should be_exit(:success)
      end
      
      it "should create new object" do
        @get.status.should eql(200)
      end
      
      it "should preserve content-type" do
        @get.headers['Content-Type'].should eql('text/plain')
      end

      it "should have same object body" do
        @get.body.should eql(read_file('foo.txt'))
      end
    end
    
    after(:all) do
      purge_bucket('copy_between_one')
      purge_bucket('copy_between_two')
    end
    
  end
  
end