module HP
  module Scalene
    class CLI < Thor
    
      desc "buckets:add <name>", "add a bucket"
      long_desc <<-DESC
  Add a new bucket to your storage account. Bucket name can be specified with 
  or without the preceding colon: 'my_bucket' or ':my_bucket'.

Examples:
  scalene bucket:add :my_bucket  # Creates a new bucket called 'my_bucket'

Aliases: none
      DESC
      method_option :force, :default => false, :type => :boolean, :aliases => '-f', :desc => "Don't prompt if bucket name is not valid virtual host."
      define_method "buckets:add" do |name|
        begin
          name = Bucket.bucket_name_for_service(name)
          if acceptable_name?(name, options)
            connection.directories.create(:key => name)
            display "Created bucket '#{name}'."
          end
        rescue Excon::Errors::Conflict => error
          display_error_message(error, :permission_denied)
        rescue Fog::HP::Storage::NotFound => error
          error 'The bucket name specified is invalid. Please see API documentation for valid naming guidelines.', :permission_denied
        end 
      end
      
      private
      
      def acceptable_name?(name, options)
        Bucket.valid_virtualhost?(name) or options[:force] or yes?('Specified bucket name is not a valid virtualhost, continue anyway?')
      end
    
    end
  end
end