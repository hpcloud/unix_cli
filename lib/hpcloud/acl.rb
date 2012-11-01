module HP
  module Cloud
    class Acl
      VALID_ACLS = ["r", "rw", "w"]
      OLD_ACLS = ["private", "public-read"]

      attr_reader :permissions, :users
      attr_reader :error_string, :error_code

      def initialize(permissions, users)
        @permissions = permissions.downcase
        @users = users
        @users = nil if @users.nil? || @users.empty?
        unless VALID_ACLS.include?(@permissions)
          unless OLD_ACLS.include?(@permissions)
            @error_string = "Your permissions '#{@permissions}' are not valid.\nValid settings are: #{VALID_ACLS.join(', ')}" 
            @error_code = :incorrect_usage
          end
        end
      end

      def is_public?
        return @users.nil?
      end

      def is_valid?
        return @error_string.nil?
      end

      def to_s
        @permissions
      end
    end
  end
end
