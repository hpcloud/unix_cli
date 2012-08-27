require 'progressbar'

module HP
  module Cloud
    class CLI < Thor
    
      map 'cp' => 'copy'

      desc 'copy <resource> <resource>', "copy files from one resource to another"
      long_desc <<-DESC
  Copy a file between your file system and a container, inside a container, or
  between containers. Optionally, an availability zone can be passed.

Examples:
  hpcloud copy my_file.txt :my_container        # Copy file to container 'my_container'
  hpcloud copy :my_container/file.txt file.txt  # Copy file.txt to local file
  hpcloud copy :logs/today :logs/old/weds       # Copy inside a container
  hpcloud copy :one/file.txt :two/file.txt      # Copy file.txt between containers
  hpcloud copy :one /usr/local                  # Copy container to /usr/local
  hpcloud copy /usr/local :two                  # Copy /usr/local to container
  hpcloud copy my_file.txt :my_container -z region-a.geo-1   # Optionally specify an availability zone

Aliases: cp

      DESC
      CLI.add_common_options
      def copy(*source, destination)
        cli_command(options) {
          to = Resource.create(Connection.instance.storage, destination)
          if source.length > 1 && to.isDirectory() == false
            error("The destination '#{destination}' for multiple files must be a directory or container", :general_error)
          end
          source.each { |name|
            from = Resource.create(Connection.instance.storage, name)
            if to.copy(from)
              display "Copied #{from.fname} => #{to.fname}"
            else
              error to.error_string, to.error_code
            end
          }
        }
      end
    end
  end
end
