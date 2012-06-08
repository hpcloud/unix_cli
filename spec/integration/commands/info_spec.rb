require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Info command" do
  
  it "should display banner and current version" do
    run_command('info').should include('Version:')
  end

end
