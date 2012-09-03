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
        response, exit_status = run_command('copy spec/fixtures/files/cantread.txt :my_container').stderr_and_exit_status
        response.should eql("Permission denied - spec/fixtures/files/cantread.txt\n")
        exit_status.should be_exit(:permission_denied)
      end
      
      after(:all) do
        File.chmod(0644, 'spec/fixtures/files/cantread.txt')
      end
    end
    
    context "when container does not exist" do
      it "should exit with container not found" do
        rsp = cptr("copy spec/fixtures/files/foo.txt :missing_container")
        rsp.stderr.should eq("You don't have a container 'missing_container'.\n")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:not_found)
      end
    end

    pending "when container is public-read but remote file cannot be overwritten" do
      it "should exit with permission denied" do
        @file_name='spec/fixtures/files/Matryoshka/Putin/Medvedev.txt'
        cptr("container:add -a secondary public_read_container")
        cptr("copy -a secondary #{file_name} :public_read_container")

        rsp = cptr("copy #{file_name} :public_read_container")

        rsp.stderr.should eq("Permission denied\n")
        rsp.exit_status.should be_exit(:permission_denied)
      end
    end
    
    context "when file and container exist" do
      it "should copy" do
        rsp = cptr("copy spec/fixtures/files/foo.txt :my_container")

        rsp.stderr.should eq("")
        rsp.stdout.should eq("Copied spec/fixtures/files/foo.txt => :my_container\n")
        rsp.exit_status.should be_exit(:success)
        @head = @hp_svc.head_object('my_container', 'foo.txt')
        @head.status.should eql(200)
        @head.headers["Content-Type"].should eq('text/plain')
      end
    end

    context "when local file has spaces in name" do
      it "should copy" do
        rsp = cptr("copy 'spec/fixtures/files/with space.txt' :my_container")
        rsp.stderr.should eql("")
        rsp.stdout.should eql("Copied spec/fixtures/files/with space.txt => :my_container\n")
        rsp.exit_status.should be_exit(:success)
        @get = @hp_svc.get_object('my_container', 'with space.txt')
      end

    end
    
    after(:all) { purge_container('my_container') }
  end
  
  context "copying remote object to local filesystem" do
    
    before(:all) { create_container_with_files('copy_remote_to_local', 'foo.txt') }
    
    context "when container does not exist" do
      it "should exit with container not found" do
        rsp = cptr("copy :copy_blah/foo.txt /tmp/foo.txt")
        rsp.stderr.should eq("You don't have a container 'copy_blah'.\n")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:not_found)
      end
    end
    
    context "when object does not exist" do
      it "should exit with object not found" do
        rsp = cptr("copy :copy_remote_to_local/foo2.txt /tmp/foo.txt")
        rsp.stderr.should eq("No files found matching source 'foo2.txt'\n")
        rsp.stderr.should eq("")
        rsp.exit_status.should be_exit(:not_found)
      end 
    end
    
    context "when local directory structure does not exist" do
      it "should exit with directory not present" do
        rsp = cptr("copy :copy_remote_to_local/foo.txt /blah/foo.txt")
        rsp.stderr.should eq("No directory exists at '/blah'.\n")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:not_found)
      end
    end

    context "when local directory and object exist" do
      it "should describe copy" do
        rsp = cptr("copy :copy_remote_to_local/foo.txt spec/tmp/foo.txt")

        rsp.stderr.should eq("")
        rsp.stdout.should eq("Copied :copy_remote_to_local/foo.txt => spec/tmp/foo.txt\n")
        rsp.exit_status.should be_exit(:success)
        File.exists?('spec/tmp/foo.txt').should be_true
        get = @hp_svc.get_object('copy_remote_to_local', 'foo.txt')
        File.read('spec/tmp/foo.txt').should eql(get.body)
      end

      after(:all) do
        begin
          File.unlink('spec/tmp/foo.txt')
        rescue Exception => e
        end
      end
    end

    context "when target is local directory" do
      it "should describe copy" do
        rsp = cptr("copy :copy_remote_to_local/foo.txt spec/tmp/")

        rsp.stderr.should eq("")
        rsp.stdout.should eq("Copied :copy_remote_to_local/foo.txt => spec/tmp/\n")
        rsp.exit_status.should be_exit(:success)
        File.exists?('spec/tmp/foo.txt').should be_true
      end

      after(:all) do
        begin
          File.unlink('spec/tmp/foo.txt')
        rescue Exception => e
        end
      end

    end
    
    context 'when cannot write file' do
      
      context "when location is unwritable" do
        before(:all) do
          Dir.mkdir('spec/tmp/unwriteable') unless File.directory?('spec/tmp/unwriteable')
          File.chmod(0000, 'spec/tmp/unwriteable')
        end

        it "should show failure message" do
          rsp = cptr("copy :copy_remote_to_local/foo.txt spec/tmp/unwriteable/")

          dir=Dir.pwd
          rsp.stderr.should eql("Permission denied - #{dir}/spec/tmp/unwriteable/foo.txt\n")
          rsp.stdout.should eql("")
          rsp.exit_status.should be_exit(:permission_denied)
        end
      end

      context "when location does not exist" do
        before(:all) do
          Dir.rmdir('spec/tmp/nonexistent') if File.directory?('spec/tmp/nonexistent')
        end

        it "should show failure message" do
          rsp = cptr("copy :copy_remote_to_local/foo.txt spec/tmp/nonexistent/")

          dir=Dir.pwd
          rsp.stderr.should eq("No directory exists at '#{dir}/spec/tmp/nonexistent'.\n")
          rsp.stdout.should eq("")
          rsp.exit_status.should be_exit(:not_found)
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
        rsp = cptr("copy :missing_container/foo.txt :missing_container/tmp/foo.txt")
        rsp.stderr.should eq("You don't have a container 'missing_container'.\n")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:not_found)
      end
    end
    
    context "when object does not exist" do
      it "should exit with object not found" do
        rsp = cptr("copy :copy_inside_container/missing.txt :copy_inside_container/tmp/missing.txt")
        rsp.stderr.should eq("No files found matching source 'missing.txt'\n")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:not_found)
      end
    end
    
    context "when container and object exist" do
      it "should exit with object copied" do
        rsp = cptr("copy :copy_inside_container/foo.txt :copy_inside_container/new/foo.txt")

        rsp.stderr.should eq("")
        rsp.stdout.should eq("Copied :copy_inside_container/foo.txt => :copy_inside_container/new/foo.txt\n")
        @exit_status.should be_exit(:success)
        @get = @hp_svc.get_object('copy_inside_container', 'new/foo.txt')
        @get.status.should eql(200)
        @get.headers['Content-Type'].should eql('application/json')
        @get.body.should eql(read_file('foo.txt'))
      end
    end
    
    context "when target not absolutely specified" do
      
      before(:all) do
        @hp_svc.put_object('copy_inside_container', 'nested/file.txt', read_file('foo.txt'), {'Content-Type' => 'text/plain'})
      end
      
      context "when container only" do
        it "should show success message" do
          rsp = cptr("copy :copy_inside_container/nested/file.txt :copy_inside_container")
          rsp.stderr.should eq("")
          rsp.stdout.should eq("Copied :copy_inside_container/nested/file.txt => :copy_inside_container\n")
          rsp.exit_status.should be_exit(:success)
        end
      end
      
      context "when directory in container" do
        it "should show success message" do
          rsp = cptr("copy :copy_inside_container/nested/file.txt :copy_inside_container/nested_new/file.txt")
          rsp.stderr.should eq("")
          rsp.stdout.should eq("Copied :copy_inside_container/nested/file.txt => :copy_inside_container/nested_new/file.txt\n")
          rsp.exit_status.should be_exit(:success)
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
        rsp = cptr("copy :missing_container/foo.txt :copy_between_two/tmp/foo.txt")

        rsp.stderr.should eq("You don't have a container 'missing_container'.\n")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:not_found)
      end
    end
    
    context "when object does not exist" do
      it "should exit with object not found" do
        rsp = cptr("copy :copy_between_one/missing.txt :copy_between_two/tmp/missing.txt")
        rsp.stderr.should eq("No files found matching source 'missing.txt'\n")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:not_found)
      end
    end
    
    context "when new container does not exist" do
      it "should exit with object not found" do
        rsp = cptr("copy :copy_between_one/foo.txt :missing_container/tmp/missing.txt")
        rsp.stderr.should eq("You don't have a container 'missing_container'.\n")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:not_found)
      end
    end
    
    context "when target is not absolutely specified" do

      before(:all) do
        @hp_svc.put_object('copy_between_one', 'nested/file.txt', read_file('foo.txt'), {'Content-Type' => 'text/plain'})
      end

      context "when container only" do
        it "should show success message" do
          rsp = cptr("copy :copy_between_one/nested/file.txt :copy_between_two")

          rsp.stderr.should eq("")
          rsp.stdout.should eq("Copied :copy_between_one/nested/file.txt => :copy_between_two\n")
          rsp.exit_status.should be_exit(:success)
        end
      end

      context "when directory in container" do
        it "should show success message" do
          rsp = cptr("copy :copy_between_one/nested/file.txt :copy_between_two/nested_new/file.txt")

          rsp.stderr.should eq("")
          rsp.stdout.should eq("Copied :copy_between_one/nested/file.txt => :copy_between_two/nested_new/file.txt\n")
          rsp.exit_status.should be_exit(:success)
        end
      end

    end

    context "when object is copied successfully" do
      it "should exit with object copied" do
        rsp = cptr("copy :copy_between_one/foo.txt :copy_between_two/new/foo.txt")
        rsp.stderr.should eq("")
        rsp.stdout.should eq("Copied :copy_between_one/foo.txt => :copy_between_two/new/foo.txt\n")
        rsp.exit_status.should be_exit(:success)
        @get = @hp_svc.get_object('copy_between_two', 'new/foo.txt')
        @get.status.should eql(200)
        @get.headers['Content-Type'].should eql('application/json')
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
        rsp = cptr('copy spec/fixtures/files/foo.txt :my_avl_container -z region-a.geo-1')

        rsp.stderr.should eq("")
        rsp.stdout.should eq("Copied spec/fixtures/files/foo.txt => :my_avl_container\n")
        rsp.exit_status.should be_exit(:success)
      end
    end

    context "copy with invalid avl" do
      it "should report error" do
        rsp = cptr('copy spec/fixtures/files/foo.txt :my_avl_container -z blah')
        rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:general_error)
      end

      after(:all) { Connection.instance.clear_options() }
    end

    after(:all) { purge_container('my_avl_container') }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("copy spec/fixtures/files/foo.txt :my_avl_container -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
