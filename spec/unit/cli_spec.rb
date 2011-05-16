require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Built-in help for all commands" do
  
  it "should list active tasks" do
    run_command('help').should include('Tasks:')
  end
  
  it "should exit successfully" do
    run_command('help').exit_status.should be_exit(:success)
  end
  
end

describe "Built-in help for a single command" do
  
  it "should show usage" do
    run_command('help copy').should include('Usage:')
  end
  
  it "should exit successfully" do
    run_command('help copy').exit_status.should be_exit(:success)
  end
  
end