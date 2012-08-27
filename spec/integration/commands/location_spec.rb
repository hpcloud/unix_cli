require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'location command' do

  before(:all) do
    @hp_svc = storage_connection
    @other = storage_connection(:secondary)
  end

  context "run on missing container" do

    before(:all) do
      @response, @exit = run_command('location :my_missing_container').stderr_and_exit_status
    end

    it "should show fail message" do
      @response.should eql("No container named 'my_missing_container' exists.\n")
    end
    its_exit_status_should_be(:not_found)

  end

  context "run on missing object" do

    before(:all) do
      @hp_svc.put_container('my_empty_container')
      @response, @exit = run_command('location :my_empty_container/file').stderr_and_exit_status
    end

    it "should show fail message" do
      @response.should eql("No object exists at 'my_empty_container/file'.\n")
    end
    its_exit_status_should_be(:not_found)

    after(:all) { purge_container('my_empty_container') }

  end

  context "run without permission for container" do

    before(:all) do
      @other.put_container('someone_elses')
      @response, @exit = run_command('location :someone_elses').stderr_and_exit_status
    end

    it "should display error message" do
      @response.should eql("No container named 'someone_elses' exists.\n")
    end
    its_exit_status_should_be(:not_found)

    after(:all) { purge_container('someone_elses', :connection => @other) }
  end

  context "run without permissions for object" do

    before(:all) do
      @other.put_container('someone_elses')
      #### @other.put_container_acl('someone_elses', 'public-read')
      @other.put_object('someone_elses', 'foo.txt', read_file('foo.txt'))
      @response, @exit = run_command('location :someone_elses/foo.txt').stderr_and_exit_status
    end

    it "should display error message" do
      @response.should eql("No object exists at 'someone_elses/foo.txt'.\n")
    end
    its_exit_status_should_be(:not_found)

    after(:all) { purge_container('someone_elses', :connection => @other) }

  end

  context "run with permissions on container" do

    before(:all) do
      @hp_svc.put_container('my_location_container')
      @response, @exit = run_command('location :my_location_container').stdout_and_exit_status
    end

    context "with avl settings from config" do
      it "should return location" do
        @response.should eql("#{@hp_svc.url}/my_location_container\n")
      end
      its_exit_status_should_be(:success)
    end

    describe "with avl settings passed in" do
      context "location for container with valid avl" do
        it "should report success" do
          response, exit_status = run_command('location :my_location_container -z region-a.geo-1').stdout_and_exit_status
          exit_status.should be_exit(:success)
        end
      end
      context "location for container with invalid avl" do
        it "should report error" do
          response, exit_status = run_command('location :my_location_container -z blah').stderr_and_exit_status
          response.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
          exit_status.should be_exit(:general_error)
        end
        after(:all) { Connection.instance.clear_options() }
      end
    end

    after(:all) { purge_container('my_location_container') }

  end

  context "run with permissions on file" do

    before(:all) do
      @hp_svc.put_container('my_location_container')
      @hp_svc.put_object('my_location_container', 'tiny.txt', read_file('foo.txt'))
      @response, @exit = run_command('location :my_location_container/tiny.txt').stdout_and_exit_status
    end

    context "with avl settings from config" do
      it "should return location" do
        @response.should eql("#{@hp_svc.url}/my_location_container/tiny.txt\n")
      end
      its_exit_status_should_be(:success)
    end

    describe "with avl settings passed in" do
      context "location for file with valid avl" do
        it "should report success" do
          response, exit_status = run_command('location :my_location_container/tiny.txt -z region-a.geo-1').stdout_and_exit_status
          exit_status.should be_exit(:success)
        end
      end
      context "location for file with invalid avl" do
        it "should report error" do
          response, exit_status = run_command('location :my_location_container/tiny.txt -z blah').stderr_and_exit_status
          response.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
          exit_status.should be_exit(:general_error)
        end
        after(:all) { Connection.instance.clear_options() }
      end
    end

    after(:all) { purge_container('my_location_container') }

  end


end
