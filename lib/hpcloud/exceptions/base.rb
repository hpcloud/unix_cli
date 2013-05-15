module HP
  module Cloud
    module Exceptions
      class Base < Exception
        attr_accessor :status

        def initialize(message, status = :general_error)
          super(message)
          @status = status
        end
      end
    end
  end
end
