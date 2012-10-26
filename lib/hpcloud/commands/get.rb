module HP
  module Cloud
    class CLI < Thor

      map %w(fetch) => 'get'

      desc 'get object [object ...]', 'Fetch objects to your local directory.'
      long_desc <<-DESC
  Copy remote objects from a container to your current directory. Optionally, an availability zone can be passed.

Examples: 
  hpcloud get :my_container/file.txt :my_container/resume.txt # copy file.txt and resume.txt to current directory
  hpcloud get :my_container/file.txt -z region-a.geo-1   # Optionally specify an availability zone

Aliases: fetch
      DESC
      CLI.add_common_options
      def get(source, *sources)
        cli_command(options) {
          sources = [source] + sources
          to = Resource.create(Connection.instance.storage, ".")
          sources.each { |name|
            from = Resource.create(Connection.instance.storage, name)
            if from.isRemote() == false
              error_message "Source object does not appear to be remote '#{from.fname}'.", :incorrect_usage
            elsif to.copy(from)
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

