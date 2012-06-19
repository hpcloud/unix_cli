require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include HP::Cloud

describe "Valid source" do

  context "when local file" do
    it "is real file true" do
      to = Resource.create(__FILE__)

      to.valid_source().should be_true

      to.error_string.should be_nil
      to.error_code.should be_nil
    end
  end

  context "when local file" do
    it "is bogus file false" do
      to = Resource.create("bogus.txt")

      to.valid_source().should be_false

      to.error_string.should eq("File not found at 'bogus.txt'.")
      to.error_code.should eq(:not_found)
    end
  end
end

describe "Set destination" do
  
  context "when local directory" do
    it "valid destination true" do
      to = Resource.create("spec/tmp")
      from = Resource.create("file.txt")

      rc = to.set_destination(from)

      rc.should be_true
      to.error_string.should be_nil
      to.error_code.should be_nil
      to.destination.should eq("spec/tmp/file.txt")
    end
  end

  context "when local renaming original file" do
    it "valid destination true" do
      to = Resource.create("spec/tmp/new.txt")
      from = Resource.create("file.txt")

      rc = to.set_destination(from)

      rc.should be_true
      to.error_string.should be_nil
      to.error_code.should be_nil
      to.destination.should eq("spec/tmp/new.txt")
    end
  end

  context "when bogus local directory" do
    it "valid destination false" do
      to = Resource.create("completely/bogus")
      from = Resource.create("file.txt")

      rc = to.set_destination(from)

      rc.should be_false
      to.error_string.should eq("No directory exists at 'completely'.")
      to.error_code.should eq(:not_found)
      to.destination.should eq("completely/bogus")
    end
  end
  
  context "when local directory" do
    it "valid destination true" do
      to = Resource.create("spec/tmp/")
      from = Resource.create("/etc/init.d/")

      rc = to.set_destination(from)

      rc.should be_true
      to.error_string.should be_nil
      to.error_code.should be_nil
      to.destination.should eq("spec/tmp/init.d")
    end
  end
  
end
