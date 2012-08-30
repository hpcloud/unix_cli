require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Move command" do
  
  before(:all) do
    @hp_svc = storage_connection
    @hp_svc.put_container('move_source_container')
    @hp_svc.put_container('move_target_container')
  end
  
  context "Moving an object inside of a container" do
    
    context "when source container can't be found" do
      it "should display error message" do
        rsp = cptr("move :missing_container/missing_file :missing_container/new/my_file")
        rsp.stderr.should eq("You don't have a container 'missing_container'.\n")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:not_found)
      end
    end
    
    context "when source file can't be found" do
      it "should display error message" do
        rsp = cptr("move :move_source_container/missing_file :move_source_container/new/my_file")
        rsp.stderr.should eq("No files found matching source 'missing_file'\n")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:not_found)
      end
    end
    
    pending "when destination file can't be written" do
    end
    
    context "when move is completed successfully" do
      it "should have created new object at destination" do
        @hp_svc.put_object('move_source_container', 'foo.txt', read_file('foo.txt'))

        rsp = cptr("move :move_source_container/foo.txt :move_source_container/new/foo.txt")

        rsp.stderr.should eq("")
        rsp.stdout.should eq("Moved :move_source_container/foo.txt => :move_source_container/new/foo.txt\n")
        rsp.exit_status.should be_exit(:success)
        @hp_svc.head_object('move_source_container', 'new/foo.txt').status.should eql(200)
        lambda {
          @hp_svc.head_object('move_source_container', 'foo.txt')
        }.should raise_error(Fog::Storage::HP::NotFound)
      end
    end

    describe "with avl settings passed in" do
      before(:all) do
        @hp_svc.put_object('move_source_container', 'foo.txt', read_file('foo.txt'))
      end

      context "move with valid avl" do
        it "should report success" do
          rsp = cptr("move :move_source_container/foo.txt :move_source_container/new/foo.txt -z region-a.geo-1")

          rsp.stderr.should eq("")
          rsp.stdout.should eq("Moved :move_source_container/foo.txt => :move_source_container/new/foo.txt\n")
          rsp.exit_status.should be_exit(:success)
        end
      end

      context "move with invalid avl" do
        it "should report error" do
          rsp = cptr("move :move_source_container/foo.txt :move_source_container/new/foo.txt -z blah")

          rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
          rsp.stdout.should eq("")
          rsp.exit_status.should be_exit(:general_error)
        end
        after(:all) { Connection.instance.clear_options() }
      end
    end

  end
  
  context "Moving an object between containers" do
    context "when source container can't be found" do
      it "should display error message" do
        rsp = cptr("move :missing_container/missing_file :move_target_container/new/my_file")

        rsp.stderr.should eq("You don't have a container 'missing_container'.\n")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:not_found)
      end
    end
    
    context "when source file can't be found" do
      it "should display error message" do
        rsp = cptr("move :move_source_container/missing :move_target_container")

        rsp.stderr.should eq("No files found matching source 'missing'\n")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:not_found)
      end
    end
    
    context "when target container can't be found" do
       it "should display error message" do
         rsp = cptr("move :missing_container/missing_file :missing_container/new/my_file")

         rsp.stderr.should eq("You don't have a container 'missing_container'.\n")
         rsp.stdout.should eq("")
         rsp.exit_status.should be_exit(:not_found)
       end
    end
    
    pending "when target file can't be written" do
    end
    
    pending "when target file written successfully" do
    end

    context "when move is completed successfully" do

      it "should have created new object at destination etc" do
        @hp_svc.put_object('move_source_container', 'foo.txt', read_file('foo.txt'))

        rsp = cptr("move :move_source_container/foo.txt :move_target_container/foo.txt")

        rsp.stderr.should eq("")
        rsp.stdout.should eq("Moved :move_source_container/foo.txt => :move_target_container/foo.txt\n")
        rsp.exit_status.should be_exit(:success)
        @hp_svc.head_object('move_target_container', 'foo.txt').status.should eql(200)
        lambda {
          @hp_svc.head_object('move_source_container', 'foo.txt')
        }.should raise_error(Fog::Storage::HP::NotFound)
      end
    end

    describe "with avl settings passed in" do
      before(:all) do
        @hp_svc.put_object('move_source_container', 'foo.txt', read_file('foo.txt'))
      end

      context "move with valid avl" do
        it "should report success" do
          rsp = cptr("move :move_source_container/foo.txt :move_target_container/foo.txt -z region-a.geo-1")

          rsp.stderr.should eql("")
          rsp.stdout.should eql("Moved :move_source_container/foo.txt => :move_target_container/foo.txt\n")
          rsp.exit_status.should be_exit(:success)
        end
      end

      context "move with invalid avl" do
        it "should report error" do
          rsp = cptr("move :move_source_container/foo.txt :move_target_container/foo.txt -z blah")

          rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
          rsp.stdout.should eq("")
          rsp.exit_status.should be_exit(:general_error)
        end

      end

      after(:all) { Connection.instance.clear_options() }
    end

  end
  
  context "Moving an object from a container to the local filesystem" do
    
    context "when source container can't be found" do
      it "should display error message" do
        rsp = cptr("move :missing_container/missing_file /tmp/my_file")

        rsp.stderr.should eql("You don't have a container 'missing_container'.\n")
        rsp.stdout.should eql("")
        rsp.exit_status.should be_exit(:not_found)
      end
    end
    
    context "when source file can't be found" do
      it "should display error message" do
        rsp = cptr("move :move_source_container/missing_file /tmp/my_file")

        rsp.stderr.should eql("No files found matching source 'missing_file'\n")
        rsp.stdout.should eql("")
        rsp.exit_status.should be_exit(:not_found)
      end
    end
    
    pending "when destination file can't be written" do
    end
    
    context "when move is completed successfully" do
      
      before(:all) do
        @hp_svc.put_object('move_source_container', 'foo.txt', read_file('foo.txt'))
        File.unlink('spec/tmp/newfoo.txt') if File.exists?('spec/tmp/newfoo.txt')
      end
      
      it "should have created new object at destination etc" do
        rsp = cptr("move :move_source_container/foo.txt spec/tmp/newfoo.txt")

        rsp.stderr.should eq("")
        rsp.stdout.should eq("Moved :move_source_container/foo.txt => spec/tmp/newfoo.txt\n")
        rsp.exit_status.should be_exit(:success)
        File.exists?('spec/tmp/newfoo.txt').should be_true
        lambda {
          @hp_svc.head_object('move_source_container', 'foo.txt')
        }.should raise_error(Fog::Storage::HP::NotFound)
      end

      after(:all) { File.unlink('spec/tmp/newfoo.txt') }
    end
    
    
  end
  
  context "Trying to move a non-object resource" do
    it "should give error message" do
      rsp = cptr("move spec/fixtures/files/foo.txt :my_container")

      rsp.stderr.should eq("Move is limited to objects within containers. Please use 'hpcloud copy' instead.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:incorrect_usage)
    end
  end
  
  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("move -a bogus :something/file.txt :somewhere")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end

  after(:all) do
    purge_container('move_source_container')
    purge_container('move_target_container')
  end
end
