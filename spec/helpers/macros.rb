
module CustomMacros
  
  def its_exit_status_should_be(status)
    it "should have exit status of #{status}" do
      exit = @exit || @exit_status
      exit.should be_exit(status)
    end
  end
  
end

# Include macros
RSpec.configure do |config|
  
  config.extend(CustomMacros)
  
end