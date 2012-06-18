require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Copy command" do
  
  before(:all) do
    @hp_svc = storage_connection
  end
  
  context "copying local file to container" do
    before(:all) do
      #purge_container('my_container')
      @hp_svc.put_container('my_container')
    end
    
    context "when local file does not exist" do
      it "should exit with file not found" do
        # response, exit_status = capture_with_status(:stderr){ HP::Cloud::CLI.start(['copy', 'foo.txt', ':my_container']) }
        response, exit_status = run_command('copy foo.txt :my_container').stderr_and_exit_status
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
        # response, exit_status = capture_with_status(:stderr){ HP::Cloud::CLI.start(['copy', 'spec/fixtures/files/cantread.txt', ':my_container']) }
        response, exit_status = run_command('copy spec/fixtures/files/cantread.txt :my_container').stderr_and_exit_status
        response.should eql("The selected file cannot be read.\n")
        exit_status.should be_exit(:permission_denied)
      end
      
      after(:all) do
        File.chmod(0644, 'spec/fixtures/files/cantread.txt')
      end
    end
    
    context "when container does not exist" do
      it "should exit with container not found" do
        response, exit_status = capture_with_status(:stderr){ HP::Cloud::CLI.start(['copy', 'spec/fixtures/files/foo.txt', ':missing_container']) }
        response.should eql("You don't have a container 'missing_container'.\n")
        exit_status.should be_exit(:not_found)
      end
    end

    pending "when container is public-read but remote file cannot be overwritten" do
      before(:all) do
        @hp_svc_other_user = storage_connection(:secondary)
        @hp_svc_other_user.put_container('public_read_container')
        #### @hp_svc_other_user.put_container_acl('public_read_container', 'public-read')
        @hp_svc_other_user.put_object('public_read_container', 'foo.txt', read_file('foo.txt'), {'Content-Type' => 'text/plain'})
      end

      it "should exit with permission denied" do
        response, exit_status = capture_with_status(:stderr){ HP::Cloud::CLI.start(['copy', 'spec/fixtures/files/foo.txt', ':public_read_container/foo.txt']) }
        response.should eql("Permission denied\n")
        exit_status.should be_exit(:permission_denied)
      end

      after(:all) do
        purge_container('public_read_container', {:connection => @hp_svc_other_user})
      end
    end
    
    context "when file and container exist" do
      before(:all) do
        @response, @exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['copy', 'spec/fixtures/files/foo.txt', ':my_container']) }
        @head = @hp_svc.head_object('my_container', 'foo.txt')
      end
      
      it "should report success" do
        @response.should eql("Copied spec/fixtures/files/foo.txt => :my_container/foo.txt\n")
        @exit_status.should be_exit(:success)
      end
      
      it "should copy file to container" do
        @head.status.should eql(200)
      end
      
      it "should preserve content-type" do
        @head.headers["Content-Type"].should eq('text/plain')
      end
      
    end

    context "when local file has spaces in name" do
      before(:all) do
        @response, @exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['copy', 'spec/fixtures/files/with space.txt', ':my_container']) }
        @get = @hp_svc.get_object('my_container', 'with space.txt')
      end

      it "should report success" do
        @response.should eql("Copied spec/fixtures/files/with space.txt => :my_container/with space.txt\n")
        @exit_status.should be_exit(:success)
      end

    end
    
    after(:all) { purge_container('my_container') }
  end
  
  context "copying remote object to local filesystem" do
    
    before(:all) { create_container_with_files('copy_remote_to_local', 'foo.txt') }
    
    context "when container does not exist" do
      it "should exit with container not found" do
        response, exit_status = capture_with_status(:stderr){ HP::Cloud::CLI.start(['copy', ':copy_blah/foo.txt', '/tmp/foo.txt']) }
        response.should eql("You don't have a container 'copy_blah'.\n")
        exit_status.should be_exit(:not_found)
      end
    end
    
    context "when object does not exist" do
      it "should exit with object not found" do
        response, exit_status = capture_with_status(:stderr){ HP::Cloud::CLI.start(['copy', ':copy_remote_to_local/foo2.txt', '/tmp/foo.txt']) }
        response.should eql("The specified object does not exist.\n")
        exit_status.should be_exit(:not_found)
      end 
    end
    
    context "when local directory structure does not exist" do
      it "should exit with directory not present" do
        response, exit_status = capture_with_status(:stderr){ HP::Cloud::CLI.start(['copy', ':copy_remote_to_local/foo.txt', '/blah/foo.txt']) }
        response.should eql("No directory exists at '/blah'.\n")
        exit_status.should be_exit(:not_found)
      end
    end

    context "when local directory and object exist" do
      before(:all) do
        @response, @exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['copy', ':copy_remote_to_local/foo.txt', 'spec/tmp/foo.txt']) }
      end
      
      it "should describe copy" do
        @response.should eql("Copied :copy_remote_to_local/foo.txt => spec/tmp/foo.txt\n")
        @exit_status.should be_exit(:success)
      end
      
      it "should create local file" do
        File.exists?('spec/tmp/foo.txt').should be_true
      end
      
      it "should have same body as object" do
        get = @hp_svc.get_object('copy_remote_to_local', 'foo.txt')
        File.read('spec/tmp/foo.txt').should eql(get.body)
      end

      after(:all) do
        File.unlink('spec/tmp/foo.txt')
      end

    end

    context "when target is local directory" do
      before(:all) do
        @response, @exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['copy', ':copy_remote_to_local/foo.txt', 'spec/tmp/']) }
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
          @response, @exit = capture_with_status(:stderr){ HP::Cloud::CLI.start(['copy', ':copy_remote_to_local/foo.txt', 'spec/tmp/unwriteable/']) }
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
          Dir.rmdir('spec/tmp/nonexistent') if File.directory?('spec/tmp/nonexistent')
          @response, @exit = capture_with_status(:stderr){ HP::Cloud::CLI.start(['copy', ':copy_remote_to_local/foo.txt', 'spec/tmp/nonexistent/']) }
        end

        it "should show failure message" do
          @response.should eql("No directory exists at 'spec/tmp/nonexistent'.\n")
        end

        it "should have correct exit status" do
          @exit.should be_exit(:not_found)
        end
        
      end
      
    end
    
    after(:all) do
      purge_container('copy_remote_to_local')
      #File.unlink('spec/tmp/foo.txt')
    end
    
  end
  
  context "copying remote object within a container" do
    
    before(:all) do
      #create_container_with_files('copy_inside_container', 'foo.txt')
      @hp_svc.put_container('copy_inside_container')
      @hp_svc.put_object('copy_inside_container', 'foo.txt', read_file('foo.txt'), {'Content-Type' => 'text/plain'})
    end
    
    context "when container does not exist" do
      it "should exit with container not found" do
        response, exit_status = capture_with_status(:stderr){ HP::Cloud::CLI.start(['copy', ':missing_container/foo.txt', ':missing_container/tmp/foo.txt']) }
        response.should eql("You don't have a container 'missing_container'.\n")
        exit_status.should be_exit(:not_found)
      end
    end
    
    context "when object does not exist" do
      it "should exit with object not found" do
        response, exit_status = capture_with_status(:stderr){ HP::Cloud::CLI.start(['copy', ':copy_inside_container/missing.txt', ':copy_inside_container/tmp/missing.txt']) }
        response.should eql("The specified object does not exist.\n")
        exit_status.should be_exit(:not_found)
      end
    end
    
    context "when container and object exist" do
      before(:all) do
        @response, @exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['copy', ':copy_inside_container/foo.txt', ':copy_inside_container/new/foo.txt']) }
        @get = @hp_svc.get_object('copy_inside_container', 'new/foo.txt')
      end
      
      it "should exit with object copied" do
        @response.should eql("Copied :copy_inside_container/foo.txt => :copy_inside_container/new/foo.txt\n")
        @exit_status.should be_exit(:success)
      end
      
      it "should create new object" do
        @get.status.should eql(200)
      end
      
      it "should preserve content-type" do
        @get.headers['Content-Type'].should eql('application/json')
      end

      it "should have same object body" do
        @get.body.should eql(read_file('foo.txt'))
      end
    end
    
    context "when target not absolutely specified" do
      
      before(:all) { @hp_svc.put_object('copy_inside_container', 'nested/file.txt', read_file('foo.txt'), {'Content-Type' => 'text/plain'}) }
      
      context "when container only" do
        it "should show success message" do
          response, exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['copy', ':copy_inside_container/nested/file.txt', ':copy_inside_container']) }
          response.should eql("Copied :copy_inside_container/nested/file.txt => :copy_inside_container/file.txt\n")
          exit_status.should be_exit(:success)
        end
      end
      
      context "when directory in container" do
        it "should show success message" do
          response, exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['copy', ':copy_inside_container/nested/file.txt', ':copy_inside_container/nested_new/file.txt']) }
          response.should eql("Copied :copy_inside_container/nested/file.txt => :copy_inside_container/nested_new/file.txt\n")
          exit_status.should be_exit(:success)
        end
      end
      
    end
    
    pending "when new object cannot be written" do  
    end
    
    after(:all) { purge_container('copy_inside_container') }
    
  end
  
  context "copying a remote object to another container" do
    
    before(:all) do
      #create_container_with_files('copy_inside_container', 'foo.txt')
      @hp_svc.put_container('copy_between_one')
      @hp_svc.put_object('copy_between_one', 'foo.txt', read_file('foo.txt'), {'Content-Type' => 'text/plain'})
      @hp_svc.put_container('copy_between_two')
    end
    
    context "when container does not exist" do
      it "should exit with container not found" do
        response, exit_status = capture_with_status(:stderr){ HP::Cloud::CLI.start(['copy', ':missing_container/foo.txt', ':copy_between_two/tmp/foo.txt']) }
        response.should eql("You don't have a container 'missing_container'.\n")
        exit_status.should be_exit(:not_found)
      end
    end
    
    context "when object does not exist" do
      it "should exit with object not found" do
        response, exit_status = capture_with_status(:stderr){ HP::Cloud::CLI.start(['copy', ':copy_between_one/missing.txt', ':copy_between_two/tmp/missing.txt']) }
        response.should eql("The specified object does not exist.\n")
        exit_status.should be_exit(:not_found)
      end
    end
    
    context "when new container does not exist" do
      it "should exit with object not found" do
        response, exit_status = capture_with_status(:stderr){ HP::Cloud::CLI.start(['copy', ':copy_between_one/missing.txt', ':missing_container/tmp/missing.txt']) }
        response.should eql("You don't have a container 'missing_container'.\n")
        exit_status.should be_exit(:not_found)
      end
    end
    
    context "when target is not absolutely specified" do

      before(:all) { @hp_svc.put_object('copy_between_one', 'nested/file.txt', read_file('foo.txt'), {'Content-Type' => 'text/plain'}) }

      context "when container only" do
        it "should show success message" do
          response, exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['copy', ':copy_between_one/nested/file.txt', ':copy_between_two']) }
          response.should eql("Copied :copy_between_one/nested/file.txt => :copy_between_two/file.txt\n")
          exit_status.should be_exit(:success)
        end
      end

      context "when directory in container" do
        it "should show success message" do
          response, exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['copy', ':copy_between_one/nested/file.txt', ':copy_between_two/nested_new/file.txt']) }
          response.should eql("Copied :copy_between_one/nested/file.txt => :copy_between_two/nested_new/file.txt\n")
          exit_status.should be_exit(:success)
        end
      end

    end

    context "when object is copied successfully" do
      before(:all) do
        @response, @exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['copy', ':copy_between_one/foo.txt', ':copy_between_two/new/foo.txt']) }
        @get = @hp_svc.get_object('copy_between_two', 'new/foo.txt')
      end
      
      it "should exit with object copied" do
        @response.should eql("Copied :copy_between_one/foo.txt => :copy_between_two/new/foo.txt\n")
        @exit_status.should be_exit(:success)
      end
      
      it "should create new object" do
        @get.status.should eql(200)
      end
      
      it "should preserve content-type" do
        @get.headers['Content-Type'].should eql('application/json')
      end

      it "should have same object body" do
        @get.body.should eql(read_file('foo.txt'))
      end
    end
    
    after(:all) do
      purge_container('copy_between_one')
      purge_container('copy_between_two')
    end
    
  end

  describe "with avl settings passed in" do
    before(:all) do
      @hp_svc.put_container('my_avl_container')
    end
    context "copy with valid avl" do
      it "should report success" do
        response, exit_status = run_command('copy spec/fixtures/files/foo.txt :my_avl_container -z region-a.geo-1').stdout_and_exit_status
        response.should eql("Copied spec/fixtures/files/foo.txt => :my_avl_container/foo.txt\n")
        exit_status.should be_exit(:success)
      end
    end
    context "copy with invalid avl" do
      it "should report error" do
        response, exit_status = run_command('copy spec/fixtures/files/foo.txt :my_avl_container -z blah').stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end
    end
    after(:all) { purge_container('my_avl_container') }
  end

end
