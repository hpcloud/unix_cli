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
        response, exit_status = capture_with_status(:stderr){ HP::Cloud::CLI.start(['move', ':missing_container/missing_file', ':missing_container/new/my_file']) }
        response.should eql("You don't have a container 'missing_container'.\n")
        exit_status.should be_exit(:not_found)
      end
    end
    
    context "when source file can't be found" do
      it "should display error message" do
        response, exit_status = capture_with_status(:stderr){ HP::Cloud::CLI.start(['move', ':move_source_container/missing_file', ':move_source_container/new/my_file']) }
        response.should eql("No files found matching source 'missing_file'\n")
        exit_status.should be_exit(:not_found)
      end
    end
    
    pending "when destination file can't be written" do
    end
    
    context "when move is completed successfully" do
      
      before(:all) do
        @hp_svc.put_object('move_source_container', 'foo.txt', read_file('foo.txt'))
        @response, @exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['move', ':move_source_container/foo.txt', ':move_source_container/new/foo.txt']) }
      end
      
      it "should have created new object at destination" do
        @hp_svc.head_object('move_source_container', 'new/foo.txt').status.should eql(200)
      end
      
      it "should have removed source object" do
        lambda {
          @hp_svc.head_object('move_source_container', 'foo.txt')
        }.should raise_error(Fog::Storage::HP::NotFound)
      end
      
      it "should display success message" do
        @response.should eql("Moved :move_source_container/foo.txt => :move_source_container/new/foo.txt\n")
        @exit_status.should be_exit(:success)
      end
      
    end

    describe "with avl settings passed in" do
      before(:all) do
        @hp_svc.put_object('move_source_container', 'foo.txt', read_file('foo.txt'))
      end
      context "move with valid avl" do
        it "should report success" do
          response, exit_status = run_command('move :move_source_container/foo.txt :move_source_container/new/foo.txt -z region-a.geo-1').stdout_and_exit_status
          response.should eql("Moved :move_source_container/foo.txt => :move_source_container/new/foo.txt\n")
          exit_status.should be_exit(:success)
        end
      end
      context "move with invalid avl" do
        it "should report error" do
          response, exit_status = run_command('move :move_source_container/foo.txt :move_source_container/new/foo.txt -z blah').stderr_and_exit_status
          response.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
          exit_status.should be_exit(:general_error)
        end
        after(:all) { Connection.instance.set_options({}) }
      end
    end

  end
  
  context "Moving an object between containers" do
    
    context "when source container can't be found" do
      it "should display error message" do
        response, exit_status = capture_with_status(:stderr){ HP::Cloud::CLI.start(['move', ':missing_container/missing_file', ':move_target_container/new/my_file']) }
        response.should eql("You don't have a container 'missing_container'.\n")
        exit_status.should be_exit(:not_found)
      end
    end
    
    context "when source file can't be found" do
      it "should display error message" do
        response, exit_status = capture_with_status(:stderr){ HP::Cloud::CLI.start(['move', ':move_source_container/missing', ':move_target_container']) }
        response.should eql("No files found matching source 'missing'\n")
        exit_status.should be_exit(:not_found)
      end
    end
    
    context "when target container can't be found" do
       it "should display error message" do
         response = capture(:stderr){ HP::Cloud::CLI.start(['move', ':missing_container/missing_file', ':missing_container/new/my_file']) }
         response.should eql("You don't have a container 'missing_container'.\n")
       end
    end
    
    pending "when target file can't be written" do
    end
    
    pending "when target file written successfully" do
    end

    context "when move is completed successfully" do

      before(:all) do
        @hp_svc.put_object('move_source_container', 'foo.txt', read_file('foo.txt'))
        @response, @exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['move', ':move_source_container/foo.txt', ':move_target_container/foo.txt']) }
      end

      it "should have created new object at destination" do
        @hp_svc.head_object('move_target_container', 'foo.txt').status.should eql(200)
      end

      it "should have removed source object" do
        lambda {
          @hp_svc.head_object('move_source_container', 'foo.txt')
        }.should raise_error(Fog::Storage::HP::NotFound)
      end

      it "should display success message" do
        @response.should eql("Moved :move_source_container/foo.txt => :move_target_container/foo.txt\n")
        @exit_status.should be_exit(:success)
      end

    end

    describe "with avl settings passed in" do
      before(:all) do
        @hp_svc.put_object('move_source_container', 'foo.txt', read_file('foo.txt'))
      end
      context "move with valid avl" do
        it "should report success" do
          response, exit_status = run_command('move :move_source_container/foo.txt :move_target_container/foo.txt -z region-a.geo-1').stdout_and_exit_status
          response.should eql("Moved :move_source_container/foo.txt => :move_target_container/foo.txt\n")
          exit_status.should be_exit(:success)
        end
      end
      context "move with invalid avl" do
        it "should report error" do
          response, exit_status = run_command('move :move_source_container/foo.txt :move_target_container/foo.txt -z blah').stderr_and_exit_status
          response.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
          exit_status.should be_exit(:general_error)
        end
        after(:all) { Connection.instance.set_options({}) }
      end
    end

  end
  
  context "Moving an object from a container to the local filesystem" do
    
    context "when source container can't be found" do
      it "should display error message" do
        response, exit_status = capture_with_status(:stderr){ HP::Cloud::CLI.start(['move', ':missing_container/missing_file', '/tmp/my_file']) }
        response.should eql("You don't have a container 'missing_container'.\n")
        exit_status.should be_exit(:not_found)
      end
    end
    
    context "when source file can't be found" do
      it "should display error message" do
        response, exit_status = capture_with_status(:stderr){ HP::Cloud::CLI.start(['move', ':move_source_container/missing_file', '/tmp/my_file']) }
        response.should eql("No files found matching source 'missing_file'\n")
        exit_status.should be_exit(:not_found)
      end
    end
    
    pending "when destination file can't be written" do
    end
    
    context "when move is completed successfully" do
      
      before(:all) do
        @hp_svc.put_object('move_source_container', 'foo.txt', read_file('foo.txt'))
        File.unlink('spec/tmp/newfoo.txt') if File.exists?('spec/tmp/newfoo.txt')
        @response, @exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['move', ':move_source_container/foo.txt', 'spec/tmp/newfoo.txt']) }
      end
      
      it "should have created new object at destination" do
        File.exists?('spec/tmp/newfoo.txt').should be_true
      end
      
      it "should have removed source object" do
        lambda {
          @hp_svc.head_object('move_source_container', 'foo.txt')
        }.should raise_error(Fog::Storage::HP::NotFound)
      end
      
      it "should display success message" do
        @response.should eql("Moved :move_source_container/foo.txt => spec/tmp/newfoo.txt\n")
        @exit_status.should be_exit(:success)
      end
      
    end
    
    after(:all) { File.unlink('spec/tmp/newfoo.txt') }
    
  end
  
  context "Trying to move a non-object resource" do
    it "should give error message" do
      response, exit_status = capture_with_status(:stderr){ HP::Cloud::CLI.start(['move', 'spec/fixtures/files/foo.txt', ':my_container']) }
      response.should eql("Move is limited to objects within containers. Please use 'hpcloud copy' instead.\n")
      exit_status.should be_exit(:incorrect_usage)
    end
  end
  
  after(:all) do
    purge_container('move_source_container')
    purge_container('move_target_container')
  end
  
end
