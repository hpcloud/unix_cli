module HPCloud
  class CLI < Thor
    
    desc 'versioning <bucket>', 'show or modify versioning state for a bucket'
    def versioning(new_state=nil)
      display "show versioning state"
    end

  end
end