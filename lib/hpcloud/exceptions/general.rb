require 'hpcloud/exceptions/base'

module HP
  module Cloud
    module Exceptions
      class General < HP::Cloud::Exceptions::Base
        def initialize(message)
          super(message)
        end
      end
    end
  end
end
