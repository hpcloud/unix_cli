require 'scalene/commands/buckets/add'
require 'scalene/commands/buckets/remove'

module HP
  module Scalene
    class CLI < Thor
    
      map 'buckets:list' => 'list'
    
      desc "buckets", "list available buckets"
      def buckets
        buckets = connection.directories
        if buckets.empty?
          display "You currently have no buckets, use `scalene buckets:add <name>` to create one."
        else
          buckets.each { |bucket| display bucket.key }
        end
      end
    
    end
  end
end