require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "ErrorResponse" do
  before(:each) do
    @response = double("response")
    @error = double("error")
  end

  context "when json" do
    it "gets json" do
      @error.stub("respond_to?").and_return(true)
      @error.stub(:response).and_return(@response)
      @response.stub(:body).and_return('{"badRequest": {"details": "Permission denied.", "message": "Unauthorized", "code": 403}}')

      msg = HP::Cloud::ErrorResponse.new(@error)

      msg.error_string.should eq("403 Unauthorized: Permission denied.")
    end
  end

  context "when response body" do
    it "gets message body" do
      @error.stub("respond_to?").and_return(true)
      @error.stub(:response).and_return(@response)
      @response.stub(:body).and_return("403 Permission Denied\n\nBlah blah")

      msg = HP::Cloud::ErrorResponse.new(@error)

      msg.error_string.should eq("403 Permission Denied\n\nBlah blah")
    end
  end

  context "when no response body" do
    it "gets message" do
      @error.stub("respond_to?").and_return(false)
      @error.stub(:message).and_return("403 Permission denied")

      msg = HP::Cloud::ErrorResponse.new(@error)

      msg.error_string.should eq("403 Permission denied")
    end
  end
end
