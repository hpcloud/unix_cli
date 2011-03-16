module HPCloud
  class CLI < Thor
    
    map 'ls' => 'list'
    
    desc 'list <bucket>', "list bucket contents"
    def list(name='')
      return buckets if name.empty?
      name = Bucket.bucket_name_for_service(name)
      begin
        directory = connection.directories.get(name)
        if directory
          directory.files.each { |file| puts file.key }
        else
          puts "You don't have a bucket named '#{name}'"
        end
      rescue Excon::Errors::Forbidden => error
        display_error_message(error)
      end
    end
    
  end
end