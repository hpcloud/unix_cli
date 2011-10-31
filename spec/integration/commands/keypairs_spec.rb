require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

#describe "Keypairs command" do
#  context "keypairs" do
#    it "should report success" do
#      response, exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['keypairs']) }
#      exit_status.should be_exit(:success)
#    end
#  end
#
#  context "keypairs:list" do
#    it "should report success" do
#      response, exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['keypairs:list']) }
#      exit_status.should be_exit(:success)
#    end
#  end
#end