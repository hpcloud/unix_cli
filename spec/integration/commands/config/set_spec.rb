require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')
require 'yaml'

describe "Config command" do
  before(:all) do
    ConfigHelper.use_tmp()
  end

  context "set availability zone for compute service" do
    before(:all) do
      @response, @exit = run_command("config:set -s compute -z blah1").stdout_and_exit_status
    end

    it "should report success" do
      @response.should eql("The configuration setting(s) have been saved to the config file.\n")
    end
    its_exit_status_should_be(:success)

    it "should write correct value in config file" do
      yaml = YAML::load(File.open(HP::Cloud::Config.config_file))
      yaml[:compute_availability_zone].should eql("blah1")
    end
  end
  context "set availability zone for storage service" do
    before(:all) do
      @response, @exit = run_command("config:set -s storage -z blah2").stdout_and_exit_status
    end

    it "should report success" do
      @response.should eql("The configuration setting(s) have been saved to the config file.\n")
    end
    its_exit_status_should_be(:success)

    it "should write correct value in config file" do
      yaml = YAML::load(File.open(HP::Cloud::Config.config_file))
      yaml[:storage_availability_zone].should eql("blah2")
    end
  end
  context "set availability zone for cdn service" do
    before(:all) do
      @response, @exit = run_command("config:set -s cdn -z blah3").stdout_and_exit_status
    end

    it "should report success" do
      @response.should eql("The configuration setting(s) have been saved to the config file.\n")
    end
    its_exit_status_should_be(:success)

    it "should write correct value in config file" do
      yaml = YAML::load(File.open(HP::Cloud::Config.config_file))
      yaml[:cdn_availability_zone].should eql("blah3")
    end
  end
  context "set availability zone for invalid service" do
    before(:all) do
      @response, @exit = run_command("config:set -s blah -z blah1").stderr_and_exit_status
    end

    it "should report error" do
      @response.should include("The service name is not valid. The service name has to be one of these: ")
    end
    its_exit_status_should_be(:not_supported)
  end

  context "no settings passed for valid service" do
    before(:all) do
      @response, @exit = run_command("config:set -s compute").stdout_and_exit_status
    end

    it "should report success" do
      @response.should eql("No configuration setting(s) were saved.\n")
    end
    its_exit_status_should_be(:success)
  end
end
