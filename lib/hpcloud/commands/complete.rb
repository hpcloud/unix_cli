require 'fileutils'

module HP
  module Cloud
    class CLI < Thor
    
      desc 'complete', "Attempt to install bash completion file."
      long_desc <<-DESC
  Running this will attempt to install the hpcloud bash completion file.  If you run this as root, it will install it in a system wide directory if there is one available.  Otherwise, it will install it in the ~/.bash_completion.d/ directory.  It is up to the user to make sure the bash completion script is run.  The ~/.bash_completion.d/ directory is normally not run by default.
  
Examples:
  hpcloud complete # Attempt to install hpcloud bash completion
      DESC
      def complete
        begin
          completion_dir = File.expand_path(File.join(File.dirname(__FILE__), '../../..', 'completion'))
          destination = '/etc/bash_completion.d/'
          unless File.writable?(destination)
            display "The system wide #{destination} directory exists, but it not writable." if File.exists?(destination)
            destination = "/opt/local/etc/bash_completion.d"
            unless File.writable?(destination)
              display "The system wide #{destination} directory exists, but it not writable." if File.exists?(destination)
              destination = "#{ENV['HOME']}/.bash_completion.d"
              FileUtils.mkdir(destination) unless File.exists?(destination)
              display "You may have to manually call the bash completion script in your .bashrc"
            end
          end
          completion_file = "#{completion_dir}/hpcloud"
          destination = "#{destination}/hpcloud"
          display "Attempting to copy #{completion_file} file to #{destination}"
          FileUtils.copy(completion_file, destination)
          display "Success"
        rescue Exception => e
          error_message "Error configuring bash completion: #{e}", :general_error
        end
      end
    end
  end
end
