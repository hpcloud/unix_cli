require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "CDN Containers command" do
  context "cdn:containers" do
    it "should report success" do
      rsp = cptr('cdn:containers')
      rsp.stderr.should eq('')
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "cdn:containers:list" do
    it "should report success" do
      rsp = cptr('cdn:containers:list')
      rsp.stderr.should eq('')
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "cdn:containers --all" do
    it "should report success" do
      rsp = cptr('cdn:containers -l')
      rsp.stderr.should eq('')
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "cdn:containers with valid avl" do
    it "should report success" do
      rsp = cptr('cdn:containers -z region-a.geo-1')
      rsp.stderr.should eq('')
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "cdn:containers with invalid avl" do
    it "should report error" do
      rsp = cptr('cdn:containers -z blah')
      rsp.stderr.should eq("Please check your HP Cloud Services account to make sure the 'Cdn' service is activated for the appropriate availability zone.\n Exception: Please check your HP Cloud Services account to make sure the 'CDN' service is activated for the appropriate availability zone.\n Exception: Unable to retrieve endpoint service url for availability zone 'blah' from service catalog. \n")
      rsp.exit_status.should be_exit(:general_error)
    end
  end

  after(:all) { Connection.instance.set_options({}) }
end
