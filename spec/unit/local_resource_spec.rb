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

describe "Open read close" do
  context "when local file" do
    it "gets the data" do
      res = Resource.create("spec/fixtures/files/foo.txt")

      res.open().should be_true
      res.read().should eq("This is a foo file.")
      res.close().should be_true
    end
  end
end

describe "Open write close" do
  before(:all) do
    begin
      File.unlink("spec/tmp/writer.txt")
    rescue Exception
    end
  end

  context "when local file" do
    it "writes data" do
      res = Resource.create("spec/tmp/")
      dest = Resource.create("writer.txt")
      res.set_destination(dest)

      res.open(true, "my data".length).should be_true
      res.write("my data").should be_true
      res.close().should be_true

      file = File.open("spec/tmp/writer.txt")
      file.read().to_s.should eq("my data")
      file.close()
      begin
        File.unlink("spec/tmp/writer.txt")
      rescue Exception
      end
    end
  end
end
