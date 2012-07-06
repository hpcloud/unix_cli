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
      method_option :availability_zone,
                    :type => :string, :aliases => '-z',
                    :desc => 'Set the availability zone.'
      def copy(from_name, to_name)
        begin
          Connection.instance.set_options(options)
          from = Resource.create(from_name)
          to   = Resource.create(to_name)
          if to.copy(from)
            display "Copied #{from.fname} => #{to.fname}"
          else
            error to.error_string, to.error_code
          end
        rescue Fog::HP::Errors::ServiceError, Fog::Storage::HP::Error => error
          display_error_message(error, :general_error)
        rescue Excon::Errors::Unauthorized => error
          display_error_message(error, :permission_denied)
        end
      end
    
    end
  end
end
