module HP
  module Cloud
    class CLI < Thor
    
      map 'cp' => 'copy'

      desc 'copy <source> [source ...] <destination>', "Copy files from one resource to another."
      long_desc <<-DESC
  Copy a file between your file system and a container, inside a container, or between containers. You may copy multiple files to a directory or container on one command line.  Optionally, you can specify an availability zone.  Note that a leading colon `:` is required when you specify a container; for example `:my_container`.

Examples:
  hpcloud copy my_file.txt :my_container        # Copy the file `my_file.txt` to container 'my_container':
  hpcloud copy :my_container/file.txt file.txt  # Copy the file `file.txt` from container `my_container` to your local system:
  hpcloud copy :logs/today :logs/old/weds       # Copy the file `today` to new location `old/weds` inside container `logs`:
  hpcloud copy :one/file.txt :two/file.txt      # Copy file.txt from container `one` to container `two`:
  hpcloud copy :one /usr/local                  # Copy container `one` to the `/usr/local` directory on your local system:
  hpcloud copy /usr/local :two                  # Copy directory `/usr/local` to container `two`:
  hpcloud copy one.txt two.txt :numbers         # Copy text files `one.txt` and `two.txt` to  container `numbers`:
  hpcloud copy my_file.txt :my_container -z region-a.geo-1   # Copy the file `my_file.txt` to container 'my_container' for availability zone `region-a.geo-1`:

Aliases: cp

      DESC
      method_option :mime,
                    :type => :string, :aliases => '-m',
                    :desc => 'Set the MIME type of the remote object.'
      method_option :source_account,
                    :type => :string, :aliases => '-s',
                    :desc => 'Source account name.'
      method_option :restart, :default => false,
                    :type => :boolean, :aliases => '-r',
                    :desc => 'Restart a previous large file upload.'
      CLI.add_common_options
      def copy(source, *destination)
        cli_command(options) {
          last = destination.pop
          source = [source] + destination
          destination = last
          to = ResourceFactory.create_any(Connection.instance.storage, destination)
          if source.length > 1 && to.isDirectory() == false
            @log.fatal("The destination '#{destination}' for multiple files must be a directory or container")
          end
          source.each { |name|
            from = ResourceFactory.create_any(Connection.instance.storage(options[:source_account]), name)
            from.set_mime_type(options[:mime])
            to.set_restart(options[:restart])
            if to.copy(from)
              @log.display "Copied #{from.fname} => #{to.fname}"
            else
              @log.fatal to.cstatus
            end
          }
        }
      end
    end
  end
end
