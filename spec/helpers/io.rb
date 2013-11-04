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
