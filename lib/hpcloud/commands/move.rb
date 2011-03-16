module HPCloud
  class CLI < Thor
    
    map 'mv' => 'move'
    
    desc 'move <resource> <resource>', 'move objects inside or between buckets'
    def move(from,to)
      puts "move an object"
    end
    
  end
end