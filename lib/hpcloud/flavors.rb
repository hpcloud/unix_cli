module HP
  module Cloud
    FLAVORS = [
      { :bits => 32, :cores =>   1,  :disk => 0,    :id =>  'm1.tiny',    :name => 'Tiny Instance',        :ram => 256},
      { :bits => 32, :cores =>   1,  :disk => 20,   :id =>  'm1.small',   :name => 'Small Instance',       :ram => 1024},
      { :bits => 32, :cores =>   2,  :disk => 40,   :id =>  'm1.medium',  :name => 'Medium Instance',      :ram => 2048},
      { :bits => 64, :cores =>   4,  :disk => 80,   :id =>  'm1.large',   :name => 'Large Instance',       :ram => 4096},
      { :bits => 64, :cores =>   8,  :disk => 160,  :id =>  'm1.xlarge',  :name => 'Extra Large Instance', :ram => 16384}
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