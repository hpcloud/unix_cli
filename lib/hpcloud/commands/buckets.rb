require 'hpcloud/commands/buckets/add'
require 'hpcloud/commands/buckets/remove'

module HPCloud
  class CLI < Thor
    
    map 'buckets:list' => 'list'
    
    desc "buckets", "list available buckets"
    def buckets
      buckets = connection.directories
      if buckets.empty?
        error "You currently have no buckets, use `hpcloud buckets:add <name>` to create one."
      else
        buckets.each { |bucket| puts bucket.key }
      end
    end
    
  end
end