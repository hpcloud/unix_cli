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

describe "Keypair keys" do
  context "when we get" do
    it "should have expected values" do
      keys = HP::Cloud::KeypairHelper.get_keys()

      keys[0].should eq("name")
      keys[1].should eq("fingerprint")
      keys.length.should eq(2)
    end
  end
end

describe "Keypair methods" do
  before(:each) do
    @fog_keypair = double("fog_keypair")
    @fog_keypair.stub(:name).and_return("skeleton")
    @fog_keypair.stub(:public_key).and_return("bones")
    @fog_keypair.stub(:private_key).and_return("cartilage")
    @fog_keypair.stub(:fingerprint).and_return("exoskeleton")
    @connection = double("connection")
  end

  context "when given fog object" do
    it "should have expected values" do
      disk = HP::Cloud::KeypairHelper.new(@connection, @fog_keypair)

      disk.id.should eq("skeleton")
      disk.name.should eq("skeleton")
      disk.public_key.should eq("bones")
      disk.private_key.should eq("cartilage")
      disk.fingerprint.should eq("exoskeleton")
      disk.cstatus.message.should be_nil
      disk.cstatus.error_code.should eq(:success)
    end
  end

  context "when given nothing" do
    it "should have expected values" do
      disk = HP::Cloud::KeypairHelper.new(@connection)

      disk.id.should be_nil
      disk.name.should be_nil
      disk.public_key.should be_nil
      disk.private_key.should be_nil
      disk.fingerprint.should be_nil
      disk.cstatus.message.should be_nil
      disk.cstatus.error_code.should eq(:success)
    end
  end

  context "when we convert to hash" do
    it "get all the expected values" do
      hash = HP::Cloud::KeypairHelper.new(@connection, @fog_keypair).to_hash()

      hash["id"].should eq("skeleton")
      hash["name"].should eq("skeleton")
      hash["public_key"].should eq("bones")
      hash["private_key"].should eq("cartilage")
      hash["fingerprint"].should eq("exoskeleton")
    end
  end

  context "when we save successfully" do
    it "it is true and we get true" do
      @new_keypair = double("new_keypair")
      @keypairs = double("keypairs")
      @keypairs.stub(:create).and_return(@new_keypair)
      @compute = double("compute")
      @compute.stub(:key_pairs).and_return(@keypairs)
      @connection = double("connection")
      @connection.stub(:compute).and_return(@compute)
      keyp = HP::Cloud::KeypairHelper.new(@connection)
      keyp.name = "roll"
      keyp.private_key = "away"
      keyp.fingerprint = "your"

      keyp.save.should be_true

      keyp.cstatus.message.should be_nil
      keyp.cstatus.error_code.should eq(:success)
    end
  end

  context "when we save public_key successfully" do
    it "it is true and we get true" do
      @new_keypair = double("new_keypair")
      @compute = double("compute")
      @compute.stub(:create_key_pair).and_return(@new_keypair)
      @connection = double("connection")
      @connection.stub(:compute).and_return(@compute)
      keyp = HP::Cloud::KeypairHelper.new(@connection)
      keyp.name = "roll"
      keyp.public_key = "away"

      keyp.save.should be_true

      keyp.cstatus.message.should be_nil
      keyp.cstatus.error_code.should eq(:success)
    end
  end

  context "when save fails" do
    it "it is false and we get errors" do
      @keypairs = double("keypairs")
      @keypairs.stub(:create).and_return(nil)
      @compute = double("compute")
      @compute.stub(:key_pairs).and_return(@keypairs)
      @connection = double("connection")
      @connection.stub(:compute).and_return(@compute)
      keyp = HP::Cloud::KeypairHelper.new(@connection)

      keyp.save.should be_false

      keyp.cstatus.message.should eq("Error creating keypair")
      keyp.cstatus.error_code.should eq(:general_error)
    end
  end

  context "private key add" do
    it "saves it" do
      @keypair = double("keypair")
      @keypair.stub(:name).and_return("cults")
      @keypair.stub(:fingerprint).and_return("fingerprint")
      @keypair.stub(:public_key).and_return("public")
      @keypair.stub(:private_key).and_return("private")
      @keypair.stub(:write).and_return(true)
      @compute = double("compute")
      @compute.stub(:key_pairs).and_return(@keypairs)
      @connection = double("connection")
      @connection.stub(:compute).and_return(@compute)
      FileUtils.stub(:chmod).and_return(true)
      keyp = HP::Cloud::KeypairHelper.new(@connection, @keypair)

      keyp.private_add.should eq("#{ENV['HOME']}/.hpcloud/keypairs/cults.pem")
    end
  end
end
