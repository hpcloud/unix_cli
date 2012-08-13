
RSpec.configure do |config|
  
  # run a CLI command - returned object is a CLITester instance, can be mined for output
  def run_command(string)
    name, *args = string.split(' ')
    CLITester.new(name, args)
  end
  
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

  # Capture everything
  def cptr(command)
    rsp = TestResponse.new
    rsp.exit_status = 0
    begin
      stdout = 'stdout'
      stderr = 'stderr'
      eval "$#{stdout} = StringIO.new"
      eval "$#{stderr} = StringIO.new"
      begin
        HP::Cloud::CLI.start(command.split(' '))
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
        actual == HP::Cloud::CLI::ERROR_TYPES[expected]
      else
        actual == expected
      end
    end

    failure_message_for_should do |actual|
      message = "expected that exit status #{actual} would be #{expected}"
      message = "#{message} (#{HP::Cloud::CLI::ERROR_TYPES[expected]})" if expected.is_a?(Symbol)
      message
    end
    failure_message_for_should_not do |actual|
      message = "expected that exit status #{actual} would not be #{expected}"
      message = "#{message} (#{HP::Cloud::CLI::ERROR_TYPES[expected]})" if expected.is_a?(Symbol)
      message
    end
  end
  
end

class CLITester
  
  def initialize(command_name, args=nil)
    @command_name = command_name.to_s
    @args = args || []
  end
  
  # def with(arguments)
  #   @args = arguments.to_s
  #   return self
  # end
  
  def stdout
    capture(:stdout){ HP::Cloud::CLI.start([@command_name, *@args]) }
  end
  
  def stderr
    capture(:stderr){ HP::Cloud::CLI.start([@command_name, *@args]) }
  end
  
  def exit_status
    capture_with_status(:stdout){ HP::Cloud::CLI.start([@command_name, *@args]) }[1]
  end
  
  def stdout_and_exit_status
    capture_with_status(:stdout){ HP::Cloud::CLI.start([@command_name, *@args]) }
  end
  
  def stderr_and_exit_status
    capture_with_status(:stderr){ HP::Cloud::CLI.start([@command_name, *@args]) }
  end
  
  def to_s
    @cached_string ||= self.stdout
  end
  
  def include?(string)
    self.to_s.include?(string)
  end
  
  private
  
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
  
end
