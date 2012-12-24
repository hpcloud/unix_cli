module HP
  module Cloud
    class CLI < Thor

      map %w(fetch) => 'get'

      desc 'get object [object ...]', 'Fetch objects to your local directory.'
      long_desc <<-DESC
  Copy remote objects from a container to your current directory. Optionally, you can specify an availability zone.

Examples: 
  hpcloud get :my_container/file.txt :my_container/resume.txt  # Copy `file.txt` and `resume.txt` to your current directory:
  hpcloud get :my_container/file.txt -z region-a.geo-1    # Copy `file.txt` to your current directory for availability zone `region-a.geo-1`:

Aliases: fetch
      DESC
      CLI.add_common_options
      def get(source, *sources)
        cli_command(options) {
          sources = [source] + sources
          to = ResourceFactory.create(Connection.instance.storage, ".")
          sources.each { |name|
            from = ResourceFactory.create(Connection.instance.storage, name)
            if from.isRemote() == false
              @log.error "Source object does not appear to be remote '#{from.fname}'.", :incorrect_usage
            elsif to.copy(from)
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

