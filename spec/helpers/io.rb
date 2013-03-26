
RSpec.configure do |config|
  
  # Capture everything
  def cptr(command, input=[])
    input.each { |x| $stdin.should_receive(:gets).and_return(x) }
    rsp = TestResponse.new
    rsp.exit_status = 0
    begin
      stdout = 'stdout'
      stderr = 'stderr'
      eval "$#{stdout} = StringIO.new"
      eval "$#{stderr} = StringIO.new"
      begin
        command = command.split(' ') if command.instance_of? String
        HP::Cloud::CLI.start(command)
      rescue SystemExit => system_exit # catch any exit calls
        rsp.exit_status = system_exit.status
      end
      rsp.stdout = eval("$#{stdout}").string
      rsp.stderr = eval("$#{stderr}").string
    ensure
      eval("$#{stdout} = #{stdout.upcase}")
      eval("$#{stderr} = #{stderr.upcase}")
    end
    return rsp
  end
  
  RSpec::Matchers.define :be_exit do |expected|
    match do |actual|
      if expected.is_a?(Symbol)
        actual == HP::Cloud::CliStatus::TYPES[expected]
      else
        actual == expected
      end
    end

    failure_message_for_should do |actual|
      message = "expected that exit status #{actual} would be #{expected}"
      message = "#{message} (#{HP::Cloud::CliStatus::TYPES[expected]})" if expected.is_a?(Symbol)
      message
    end
    failure_message_for_should_not do |actual|
      message = "expected that exit status #{actual} would not be #{expected}"
      message = "#{message} (#{HP::Cloud::CliStatus::TYPES[expected]})" if expected.is_a?(Symbol)
      message
    end
  end
  
end
