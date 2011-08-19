require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "Security Groups IP Permissions command" do
  def cli
    @cli ||= HP::Cloud::CLI.new
  end
  context "securitygroups:ippermissions" do
    before(:all) do
      @response, @exit = run_command('securitygroups:ippermissions default').stdout_and_exit_status
    end
    its_exit_status_should_be(:success)
  end

  context "securitygroups:ippermissions:list" do
    before(:all) do
      @response, @exit = run_command('securitygroups:ippermissions:list default').stdout_and_exit_status
    end
    its_exit_status_should_be(:success)
  end
end