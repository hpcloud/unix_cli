require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include HP::Cloud

describe "Valid source" do
  before(:each) do
    @co = double("connection")
  end

  context "when local file" do
    it "is real file true" do
      to = Resource.create(@co, __FILE__)

      to.valid_source().should be_true

      to.error_string.should be_nil
      to.error_code.should be_nil
    end
  end

  context "when local file" do
    it "is bogus file false" do
      to = Resource.create(@co, "bogus.txt")

      to.valid_source().should be_false

      to.error_string.should eq("File not found at 'bogus.txt'.")
      to.error_code.should eq(:not_found)
    end
  end
end

describe "Valid destination" do
  before(:each) do
    @co = double("connection")
  end

  context "when local file" do
    it "source is object and dest is real file true" do
      to = Resource.create(@co, __FILE__)

      to.valid_destination(false).should be_true

      to.error_string.should be_nil
      to.error_code.should be_nil
    end
  end

  context "when local file" do
    it "source is object and dest is nonexistent file" do
      to = Resource.create(@co, "nonexistent.txt")

      to.valid_destination(false).should be_true

      to.error_string.should be_nil
      to.error_code.should be_nil
    end
  end

  context "when local file" do
    it "source is object and dest is real directory" do
      to = Resource.create(@co, File.dirname(File.expand_path(__FILE__)))

      to.valid_destination(false).should be_true

      to.error_string.should be_nil
      to.error_code.should be_nil
    end
  end

  context "when local file" do
    it "source is object and dest is bogus directory" do
      dir = File.dirname(File.expand_path(__FILE__)) + '/bogus/'
      to = Resource.create(@co, dir)

      to.valid_destination(false).should be_false

      dir = dir.sub(/\/$/, '')
      to.error_string.should eq("No directory exists at '#{dir}'.")
      to.error_code.should eq(:not_found)
    end
  end

  context "when local file" do
    it "source is directory and dest is real file true" do
      to = Resource.create(@co, __FILE__)

      to.valid_destination(true).should be_false

      to.error_string.should eq("Invalid target for directory copy '#{__FILE__}'.")
      to.error_code.should eq(:incorrect_usage)
    end
  end

  context "when local file" do
    it "source is directory and dest is real directory" do
      to = Resource.create(@co, File.dirname(File.expand_path(__FILE__)))

      to.valid_destination(true).should be_true

      to.error_string.should be_nil
      to.error_code.should be_nil
    end
  end

  context "when local file" do
    it "source is directory and dest is bogus directory" do
      dir = File.dirname(File.expand_path(__FILE__)) + '/bogus/'
      to = Resource.create(@co, dir)

      to.valid_destination(true).should be_false

      dir = dir.sub(/\/$/, '')
      to.error_string.should eq("No directory exists at '#{dir}'.")
      to.error_code.should eq(:not_found)
    end
  end
end

describe "Set destination" do
  before(:each) do
    @co = double("connection")
  end
  
  context "when local directory" do
    it "valid destination true" do
      to = Resource.create(@co, "spec/tmp")
      from = Resource.create(@co, "file.txt")

      rc = to.set_destination("file.txt")

      rc.should be_true
      to.error_string.should be_nil
      to.error_code.should be_nil
      to.destination.should eq(Dir.pwd + "/spec/tmp/file.txt")
    end
  end

  context "when local renaming original file" do
    it "valid destination true" do
      to = Resource.create(@co, "spec/tmp/new.txt")

      rc = to.set_destination("file.txt")

      rc.should be_true
      to.error_string.should be_nil
      to.error_code.should be_nil
      to.destination.should eq(Dir.pwd + "/spec/tmp/new.txt")
    end
  end

  context "when bogus local directory" do
    it "valid destination false" do
      to = Resource.create(@co, "spec/fixtures/files/")

      rc = to.set_destination("foo.txt/impossible/subdir/file.txt")

      rc.should be_false
      dir=Dir.pwd
      to.error_string.should eq("Error creating target directory '#{dir}/spec/fixtures/files/foo.txt/impossible/subdir'.")
      to.error_code.should eq(:general_error)
      to.destination.should eq("#{dir}/spec/fixtures/files/foo.txt/impossible/subdir/file.txt")
    end
  end
  
  context "when local directory path empty" do
    it "valid destination true" do
      to = Resource.create(@co, "")

      rc = to.set_destination("file.txt")

      rc.should be_true
      to.error_string.should be_nil
      to.error_code.should be_nil
      to.destination.should eq("file.txt")
    end
  end
  
end

describe "Open read close" do
  before(:each) do
    @co = double("connection")
  end

  context "when local file" do
    it "gets the data" do
      res = Resource.create(@co, "spec/fixtures/files/foo.txt")

      res.open().should be_true
      res.read().should eq("This is a foo file.")
      res.close().should be_true
    end
  end
end

describe "Open write close" do
  before(:each) do
    @co = double("connection")
  end

  before(:all) do
    begin
      File.unlink("spec/tmp/writer.txt")
    rescue Exception
    end
  end

  context "when local file" do
    it "writes data" do
      res = Resource.create(@co, "spec/tmp/")
      dest = Resource.create(@co, "writer.txt")
      res.set_destination(dest.path)

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

describe "Read directory" do
  before(:each) do
    @co = double("connection")
  end

  context "when directory contains files" do
    it "gets all the files" do
      res = Resource.create(@co, "spec/fixtures/files/Matryoshka/Putin/Yeltsin/Gorbachev/")
      ray = Array.new

      res.foreach{ |x| ray.push(x.fname) }

      ray.sort!
      ray[0].should eq("spec/fixtures/files/Matryoshka/Putin/Yeltsin/Gorbachev/Andropov.txt")
      ray[1].should eq("spec/fixtures/files/Matryoshka/Putin/Yeltsin/Gorbachev/Chernenko.txt")
      ray[2].should eq("spec/fixtures/files/Matryoshka/Putin/Yeltsin/Gorbachev/Mikhail.txt")
      ray.length.should eq(3)
    end
  end

  context "when directory contains directories" do
    it "gets all the subdirectories" do
      res = Resource.create(@co, "spec/fixtures/")
      ray = Array.new

      res.foreach { |x| ray.push(x.fname) }

      ray.sort!
      ray[0].should eq("spec/fixtures/accounts/default")
      ray[1].should eq("spec/fixtures/configs/personalized.yml")
      ray[2].should eq("spec/fixtures/files/Matryoshka/Putin/Medvedev.txt")
      ray[3].should eq("spec/fixtures/files/Matryoshka/Putin/Vladimir.txt")
      ray[4].should eq("spec/fixtures/files/Matryoshka/Putin/Yeltsin/Boris.txt")
      ray[5].should eq("spec/fixtures/files/Matryoshka/Putin/Yeltsin/Gorbachev/Andropov.txt")
      ray[6].should eq("spec/fixtures/files/Matryoshka/Putin/Yeltsin/Gorbachev/Chernenko.txt")
      ray[7].should eq("spec/fixtures/files/Matryoshka/Putin/Yeltsin/Gorbachev/Mikhail.txt")
      ray[8].should eq("spec/fixtures/files/cantread.txt")
      ray[9].should eq("spec/fixtures/files/foo.txt")
      ray[10].should eq("spec/fixtures/files/with space.txt")
      ray.length.should eq(11)
    end
  end

  context "when file" do
    it "gets just the file" do
      res = Resource.create(@co, "spec/fixtures/files/foo.txt")
      ray = Array.new

      res.foreach { |x| ray.push(x.fname) }

      ray.sort!
      ray[0].should eq("spec/fixtures/files/foo.txt")
      ray.length.should eq(1)
    end
  end
end

describe "Get size" do
  before(:each) do
    @co = double("connection")
  end

  context "valid file" do
    it "returns size" do
      res = Resource.create(@co, "spec/fixtures/files/foo.txt")

      res.get_size().should eq(19)
    end
  end

  context "invalid file" do
    it "returns size" do
      res = Resource.create(@co, "spec/nonexistent/file.txt")

      res.get_size().should eq(0)
    end
  end

end

