module HPCloud
  class CLI < Thor
    
    map '--version' => 'info'
    
    desc "info", "info about the hpcloud CLI"
    def info
      display "Version: #{VERSION}"
    end
    
  end
end