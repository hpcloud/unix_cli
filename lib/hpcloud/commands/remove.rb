module HPCloud
  class CLI < Thor
    
    map %w(rm delete destroy del) => 'remove'
    
    desc 'remove <resource>', 'remove an object'
    def remove(resource)
      puts "remove an object"
    end
    
  end
end