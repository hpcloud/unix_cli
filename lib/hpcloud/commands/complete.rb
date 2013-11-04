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

require 'fileutils'

module HP
  module Cloud
    class CLI < Thor
    
      desc 'complete', "Installs the bash completion file."
      long_desc <<-DESC
  Installs the HP Cloud bash completion file.  If you run this command as the root user, the file is installed in a system-wide directory (if one is available).  Otherwise, the file is installed  in the `~/.bash_completion.d/` directory.  The `~/.bash_completion.d/` directory is not run by default; you must run the completion script explicitly.
  
Examples:
  hpcloud complete # Installs the HP Cloud bash completion file.
      DESC
      def complete
        begin
          completion_dir = File.expand_path(File.join(File.dirname(__FILE__), '../../..', 'completion'))
          destination = '/etc/bash_completion.d/'
          unless File.writable?(destination)
            @log.display "The system wide #{destination} directory exists, but is not writable." if File.exists?(destination)
            destination = "/opt/local/etc/bash_completion.d"
            unless File.writable?(destination)
              @log.display "The system wide #{destination} directory exists, but is not writable." if File.exists?(destination)
              destination = "#{ENV['HOME']}/.bash_completion.d"
              FileUtils.mkdir(destination) unless File.exists?(destination)
              @log.display "You may need to manually execute the bash completion script in your .bashrc"
            end
          end
          completion_file = "#{completion_dir}/hpcloud"
          destination = "#{destination}/hpcloud"
          @log.display "Attempting to copy #{completion_file} file to #{destination}"
          FileUtils.copy(completion_file, destination)
          @log.display "Success"
        rescue Exception => e
          @log.error "Error configuring bash completion: #{e}"
        end
      end
    end
  end
end
