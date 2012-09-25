require 'ruby-progressbar'

module HP
  module Cloud
    class Progress
      def initialize(name, siz)
        siz = 1 if siz <= 0
        args = { :title => File.basename(name), :total => siz}
        @pbar = ProgressBar.create(args)
      end

      def increment(siz)
        return if siz.nil?
        return if siz == 0
        @pbar.progress += siz
      end

      def finish
        @pbar.finish if @pbar.progress < @pbar.total
      end
    end
  end
end
