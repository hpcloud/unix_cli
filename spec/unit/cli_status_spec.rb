require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "CliStatus" do
  context "construct nothing" do
    it "gets success" do
      status = HP::Cloud::CliStatus.new

      status.get.should eq(0)
      status.to_s.should eq('')
    end
  end

  context "construct with values" do
    it "gets error" do
      status = HP::Cloud::CliStatus.new("shoot", :general_error)

      status.get.should eq(1)
      status.to_s.should eq('shoot')
    end
  end

  context "construct nothing and set" do
    it "gets error" do
      status = HP::Cloud::CliStatus.new

      status.set(:conflicted)

      status.get.should eq(5)
    end
  end

  context "construct priority set" do
    it "gets error" do
      status = HP::Cloud::CliStatus.new
      status.set(:permission_denied)

      status.set(:conflicted)

      status.get.should eq(77)
    end
  end

  context "construct bogus set" do
    it "gets error" do
      status = HP::Cloud::CliStatus.new

      status.set(:bogus)

      status.get.should eq(99)
    end
  end

  context "construct string set" do
    it "gets error" do
      status = HP::Cloud::CliStatus.new

      status.set('bogus')

      status.get.should eq(99)
    end
  end
end
