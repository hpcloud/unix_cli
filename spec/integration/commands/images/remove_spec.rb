require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "images:remove command" do
  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = compute_connection
    @flavor_id = 1 #tiny
    @image_id = OS_COMPUTE_BASE_IMAGE_ID
    @image_name = "fog-test-image"
    @server = @hp_svc.servers.create(:flavor_id => @flavor_id, :image_id => @image_id, :name => "fog-test-server" )
  end

  context "when deleting an image by name" do
    before(:all) do
      resp = @server.create_image(@image_name)
      @new_image_id = resp.headers["Location"].split("/")[5]
    end

    it "should show success message" do
      @response, @exit = run_command("images:remove #{@image_name}").stdout_and_exit_status
      @response.should eql("Removed image '#{@image_name}'.\n")
      sleep(10)
    end

    ### image deletes take time to get it off the list
    it "should not list in images" do
      images = @hp_svc.images.map {|i| i.id}
      images.should_not include(@new_image_id)
    end

    it "should not exist" do
      image = @hp_svc.images.get(@new_image_id)
      image.should be_nil
    end

  end

  after(:all) do
    @server.destroy
  end
end