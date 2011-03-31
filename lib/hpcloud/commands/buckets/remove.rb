module HPCloud
  class CLI < Thor
    
    map %w(buckets:rm buckets:delete buckets:del) => 'buckets:remove'
    
    desc "buckets:remove <name>", "remove a bucket"
    method_option :force, :default => false, :type => :boolean, :aliases => '-f'
    define_method "buckets:remove" do |name|
      name = Bucket.bucket_name_for_service(name)
      bucket = connection.directories.get(name)
      if bucket
        if options.force?
          bucket.files.each { |file| file.destroy }
        end
        begin
          bucket.destroy
          puts "Removed bucket '#{name}'."
        rescue Excon::Errors::Conflict => error
          display_error_message(error)
        end
      else
        error "You don't have a bucket named '#{name}'."
      end
    end
    
  end
end