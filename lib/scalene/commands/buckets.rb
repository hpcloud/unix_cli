require 'scalene/commands/buckets/add'
require 'scalene/commands/buckets/remove'

module HP
  module Scalene
    class CLI < Thor
    
      map 'buckets:list' => 'buckets'
    
      desc "buckets", "list available buckets"
      long_desc <<-DESC
  List the buckets in your storage account.
  
Examples:
  scalene buckets

Aliases: buckets:list
      DESC
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