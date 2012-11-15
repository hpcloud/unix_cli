require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Checker class" do
  before(:all) do
    CheckerHelper.use_tmp
    ConfigHelper.use_tmp
    config = HP::Cloud::Config.new
    config.set(:checker_url, CheckerHelper.latest)
    config.set(:checker_deferment, CheckerHelper.deferment)
    config.write
  end

  before(:all) do
    CheckerHelper.set_latest(0, 0, 0)
  end

  context "the checker constructor" do
    it "has some default values" do
      checker = Checker.new

      checker.file.should eq(CheckerHelper.tmp_dir + "/.hpcloud/checker")
      checker.url.should eq(CheckerHelper.latest)
      checker.deferment.should eq(CheckerHelper.deferment)
    end
  end

  context "checker no file is latest" do
    it "is false" do
      checker = Checker.new
      checker.reset
      CheckerHelper.set_latest(0, 0, 0)

      checker.process.should be_false

      checker.latest.should eq(HP::Cloud::VERSION)
    end
  end

  context "checker no file is newer build" do
    it "is false" do
      checker = Checker.new
      checker.reset
      CheckerHelper.set_latest(0, 0, -1)

      checker.process.should be_false
    end
  end

  context "checker no file is newer minor" do
    it "is false" do
      checker = Checker.new
      checker.reset
      CheckerHelper.set_latest(0, -1, 0)

      checker.process.should be_false
    end
  end

  context "checker no file is newer major" do
    it "is false" do
      checker = Checker.new
      checker.reset
      CheckerHelper.set_latest(-1, 0, 0)

      checker.process.should be_false
    end
  end

  context "checker no file is older build" do
    it "is true" do
      checker = Checker.new
      checker.reset
      latest = CheckerHelper.set_latest(0, 0, 1)

      checker.process.should be_true

      checker.process.should be_false
      checker.latest.should eq(latest)
    end
  end

  context "checker no file is older minor" do
    it "is true" do
      checker = Checker.new
      checker.reset
      CheckerHelper.set_latest(0, 1, 0)

      checker.process.should be_true

      checker.process.should be_false
    end
  end

  context "the checker after waiting deferment" do
    it "is true" do
      checker = Checker.new
      CheckerHelper.set_latest(1, 0, 0)
      checker.process
      checker.deferment = 1
      sleep(2)

      checker.process.should be_true

      checker.process.should be_false
    end
  end

  context "checker no file but is disabled" do
    it "is true" do
      checker = Checker.new
      checker.reset
      checker.deferment = 0
      CheckerHelper.set_latest(0, 1, 0)

      checker.process.should be_false
    end
  end

  context "checker no file but is disabled" do
    it "is true" do
      checker = Checker.new
      checker.reset
      checker.url = nil
      CheckerHelper.set_latest(0, 1, 0)

      checker.process.should be_false
    end
  end

  context "the checker when url is 404" do
    it "is false" do
      checker = Checker.new
      checker.url = "bogus"

      checker.process.should be_false
    end
  end

  after(:all) do
    CheckerHelper.reset
    ConfigHelper.reset
  end
end
