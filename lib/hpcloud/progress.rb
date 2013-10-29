require 'ruby-progressbar'

module HP
  module Cloud
    class Progress
      def initialize(name, siz)
        siz = 1 if siz <= 0
        args = { :title => File.basename(name), :total => siz}
        begin
          @pbar = ProgressBar.create(args)
        rescue
        end
      end

      def increment(siz)
        return if siz.nil?
        return if siz == 0
        begin
          @pbar.progress += siz
        rescue
        end
      end

      def finish
        begin
          @pbar.finish if @pbar.progress < @pbar.total
        rescue
        end
      end
    end
  end
end
