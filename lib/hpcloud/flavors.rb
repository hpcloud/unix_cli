module HP
  module Cloud
    FLAVORS = [
      { :bits => 32, :cores =>   1,  :disk => 0,    :id =>  '1',  :name => 'm1.tiny',   :ram => 512},
      { :bits => 32, :cores =>   1,  :disk => 20,   :id =>  '2',  :name => 'm1.small',  :ram => 2048},
      { :bits => 32, :cores =>   2,  :disk => 40,   :id =>  '3',  :name => 'm1.medium', :ram => 4096},
      { :bits => 64, :cores =>   4,  :disk => 80,   :id =>  '4',  :name => 'm1.large',  :ram => 8192},
      { :bits => 64, :cores =>   8,  :disk => 160,  :id =>  '5',  :name => 'm1.xlarge', :ram => 16384}
    ]

    class Flavors
      def self.all
        FLAVORS
      end

      # quick and dirty hack
      def self.table(flavors)
        if (!flavors.nil? && !flavors.empty?)
          # draw out the header
          puts "  +----------------------+" + "-----------+" + "-------+" + "-------+" + "-------+" + "-------+"
          puts "  | name                 |" + " id        |" + " cores |" + " disk  |" + " ram   |" + " bits  |"
          puts "  +----------------------+" + "-----------+" + "-------+" + "-------+" + "-------+" + "-------+"
          flavors.each do |flavor|
            puts "  | #{flavor[:name]}"  + " "*(21-(flavor[:name].length))    +
                 "| #{flavor[:id]}"    + " "*(10-(flavor[:id].length))        +
                 "| #{flavor[:cores]}" + " "*(6-(flavor[:cores].to_s.length)) +
                 "| #{flavor[:disk]}"  + " "*(6-(flavor[:disk].to_s.length))  +
                 "| #{flavor[:ram]}"   + " "*(6-(flavor[:ram].to_s.length))   +
                 "| #{flavor[:bits]}"  + " "*(5-(flavor[:bits].to_s.length))  + " |"
            puts "  +----------------------+" + "-----------+" + "-------+" + "-------+" + "-------+" + "-------+"
          end
        end
      end
    end
  end
end