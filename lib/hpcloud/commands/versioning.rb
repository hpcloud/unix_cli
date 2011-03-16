module HPCloud
  class CLI < Thor
    
    desc 'versioning <bucket>', 'show or modify versioning state for a bucket'
    def versioning(new_state=nil)
      puts "show versioning state"
    end

  end
end