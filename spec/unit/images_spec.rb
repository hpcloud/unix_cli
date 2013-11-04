# encoding: utf-8
#
# © Copyright 2013 Hewlett-Packard Development Company, L.P.
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
      
describe "Image getter" do
  def mock_image(name, id=1)
    fog_image = double("image")
    fog_image.stub(:id).and_return(id)
    fog_image.stub(:name).and_return(name)
    fog_image.stub(:created_at).and_return("today")
    fog_image.stub(:status).and_return("WORKING")
    fog_image.stub(:metadata).and_return([])
    return fog_image
  end

  before(:each) do
    @all = [ mock_image("Fedora"), mock_image("Suse"), mock_image("Gentoo") ]
    @images = double("images")
    @images.stub(:all).and_return(@all)
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
      
  context "matches" do
    it "should return true or false" do
      images = Images.new
      i1 = mock_image("2", 1)
      i2 = mock_image("1", 2)
      i3 = mock_image("three", 3)
      i4 = mock_image("tree", 4)

      images.matches("1", i1).should be_true
      images.matches("1", i2).should be_false
      images.matches("1", i3).should be_false
      images.matches("1", i4).should be_false
      images.matches("2", i1).should be_false
      images.matches("2", i2).should be_true
      images.matches("2", i3).should be_false
      images.matches("2", i4).should be_false
      images.matches("three", i1).should be_false
      images.matches("three", i2).should be_false
      images.matches("three", i3).should be_true
      images.matches("three", i4).should be_false
      images.matches("ree", i1).should be_false
      images.matches("ree", i2).should be_false
      images.matches("ree", i3).should be_true
      images.matches("ree", i4).should be_true
    end
  end 
end
