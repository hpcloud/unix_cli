require 'scalene/commands/buckets/add'
require 'scalene/commands/buckets/remove'

module HP
  module Scalene
    class CLI < Thor
    
      map 'buckets:list' => 'list'
    
      desc "buckets", "list available buckets"
      long_desc "List the buckets in your storage account. Buckets are listed in alphabetical order.
                \n\nExamples:
                \n\nscalene buckets:list
                \n\nscalene list

                \n\nAliases: 'list'
                \n\n"

      def buckets
        buckets = connection.directories
        if buckets.empty?
          display "You currently have no buckets, use `#{selfname} buckets:add <name>` to create one."
        else
          buckets.each { |bucket| display bucket.key }
        end
      end
    
    end
  end
end