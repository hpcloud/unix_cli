module HP
  module Scalene
    class CLI < Thor

      map %w(rm delete destroy del) => 'remove'

      desc 'remove <resource>', 'remove an object'
      long_desc "Remove an object or bucket. To remove a bucket, it must be empty.  If you want to remove
                a non-empty bucket, use 'scalene buckets:remove' using the -f flag.  See
                'scalene help buckets:remove for information.
                \n\nExamples:
                \n\nscalene remove :my_bucket/my_file.txt ==> Delete the file 'my_file.txt'
                \n\nscalene rm :my_bucket ==> Delete the empty bucket called 'my_bucket'

                \n\nAliases: 'rm', 'delete', 'destroy', 'del'
                \n\nNote: We currently support the deletion of one file at a time.
                    We don\'t yet support the ability to delete multiple files with a wildcard, i.e. '*.*'"

      def remove(resource)
        bucket, path = Bucket.parse_resource(resource)
        type = Resource.detect_type(resource)

        directory = connection.directories.get(bucket)
        if not directory
          error "You don't have a bucket named '#{bucket}'", :not_found
          return
        end

        if type == :object
          file = directory.files.get(path)
          if file
            file.destroy
            display "Removed object '#{resource}'."
          else
            error "You don't have a object named '#{path}'.", :not_found
          end

        elsif type == :bucket
          confirm = ask_with_default "Are you sure you want to remove '#{resource}'", 'n'
          if confirm[0].downcase == 'y'
            send('buckets:remove', bucket)
          end

        else
            error "Could not find resource '#{resource}'. Correct syntax is :bucketname/objectname."
        end
      end

    end
  end
end

