module HP
  module Scalene
    class CLI < Thor
    
      map 'ls' => 'list'
    
      desc 'list <bucket>', "list bucket contents"
      long_desc <<-DESC
  List the contents of a specified bucket.

Examples:
  scalene list :my_bucket  # list files in bucket 'my_bucket'
  scalene list             # list all buckets

Aliases: ls

Note: Listing details on files will be available in a future release.
      DESC
      def list(name='')
        return buckets if name.empty?
        name = Bucket.bucket_name_for_service(name)
        begin
          directory = connection.directories.get(name)
          if directory
            directory.files.each { |file| display file.key }
          else
            error "You don't have a bucket named '#{name}'", :not_found
          end
        rescue Excon::Errors::Forbidden => error
          display_error_message(error)
        end
      end
    
    end
  end
end