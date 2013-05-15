require 'hpcloud/exceptions/base'

module HP
  module Cloud
    module Exceptions
      class NotFound < HP::Cloud::Exceptions::Base
        def initialize(message)
          super(message, :not_found)
        end
      end
    end
  end
end
