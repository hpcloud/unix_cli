
RSpec.configure do |config|
  
  # Capture a certain io stream for anything run within the block
  #
  # Example:  output = capture('stdout') { puts 'hello world' }
  def capture(stream)
    capture_with_status(stream){ yield }[0]
  end
  
  # Capture both io stream and exit status
  #
  # Example:  output, exit_status = capture('stdout') { puts 'hello world' }
  def capture_with_status(stream)
    exit_status = 0
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      begin
        yield
      rescue SystemExit => system_exit # catch any exit calls
        exit_status = system_exit.status
      end
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end
    return result, exit_status
  end
  
  RSpec::Matchers.define :be_exit do |expected|
    match do |actual|
      if expected.is_a?(Symbol)
        actual == HP::Scalene::CLI::ERROR_TYPES[expected]
      else
        actual == expected
      end
    end

    failure_message_for_should do |actual|
      message = "expected that exit status #{actual} would be #{expected}"
      message = "#{message} (#{HP::Scalene::CLI::ERROR_TYPES[expected]})" if expected.is_a?(Symbol)
      message
    end
    failure_message_for_should_not do |actual|
      message = "expected that exit status #{actual} would not be #{expected}"
      message = "#{message} (#{HP::Scalene::CLI::ERROR_TYPES[expected]})"
      message
    end
  end
  
end