require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')
require 'yaml'

describe "Config command" do

  context "config:set" do
    before(:all) do
      setup_temp_home_directory
      HP::Cloud::Config.ensure_config_exists
    end
    context "set availability zone" do
      before(:all) do
        @response, @exit = run_command("config:set -z blah1").stdout_and_exit_status
      end

      it "should report success" do
        @response.should eql("Configuration setting have been saved to the config file.\n")
      end
      its_exit_status_should_be(:success)

      it "should write correct value in config file" do
        yaml = YAML::load(File.open(HP::Cloud::Config.config_file))
        yaml[:availability_zone].should eql("blah1")
      end
    end
  end

end