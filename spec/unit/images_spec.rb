require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
      
describe "Image getter" do
  def mock_image(name)
    fog_image = double("image")
    fog_image.stub(:id).and_return(1)
    fog_image.stub(:name).and_return(name)
    fog_image.stub(:created_at).and_return("today")
    fog_image.stub(:status).and_return("WORKING")
    fog_image.stub(:metadata).and_return([])
    return fog_image
  end

  before(:each) do
    @images = [ mock_image("Fedora"), mock_image("Suse"), mock_image("Gentoo") ]
    @compute = double("compute")
    @compute.stub(:images).and_return(@images)
    Connection.instance.stub(:compute).and_return(@compute)
  end

  context "when we get with no arguments" do
    it "should return them all" do
      images = Images.new.get()

      images[0].name.should eql("Fedora")
      images[1].name.should eql("Suse")
      images[2].name.should eql("Gentoo")
      images.length.should eql(3)
    end
  end 
      
  context "when check empty" do
    it "should return false" do
      Images.new.empty?.should be_false
    end
  end 
end
