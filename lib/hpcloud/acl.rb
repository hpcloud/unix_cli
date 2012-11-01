module HP
  module Cloud
    class Acl
      VALID_ACLS = ["r", "rw", "w"]

      attr_reader :permissions, :users
      attr_reader :error_string, :error_code

      def initialize(permissions, users)
        @permissions = permissions.downcase
        @permissions = "r" if @permissions == "public-read"
        if users.nil? || users.empty?
          @users = nil
        else
          @users = users.split(",")
        end

        if @permissions == "private"
          @error_string = "Use the acl:revoke command to revoke public read permissions"
          @error_code = :incorrect_usage
          return
        end
        unless VALID_ACLS.include?(@permissions)
          @error_string = "Your permissions '#{@permissions}' are not valid.\nValid settings are: #{VALID_ACLS.join(', ')}" 
          @error_code = :incorrect_usage
          return
        end
        @permissions = "pr" if is_public? && @permissions == "r"
        if is_public? && @permissions != "pr"
          @error_string = "You may not make an object writable by everyone"
          @error_code = :not_supported
          return
        end
      end

      def is_public?
        return @users.nil?
      end

      def is_valid?
        return @error_string.nil?
      end

      def to_s
        return "public-read" if @permissions == "pr"
        return (@permissions + " for " + @users.join(",")) unless @users.nil?
        return @permissions
      end
    end
  end
end
