module HP
  module Cloud
    class AclCmd
      VALID_ACLS = ["r", "rw", "w"]

      attr_reader :permissions, :users
      attr_reader :cstatus

      def initialize(permissions, users)
        @cstatus = CliStatus.new
        @permissions = permissions.downcase
        @permissions = "r" if @permissions == "public-read"
        if users.nil? || users.empty?
          @users = nil
        else
          @users = users
          @users = nil if users[0].empty?
        end

        if @permissions == "private"
          @cstatus = CliStatus.new("Use the acl:revoke command to revoke public read permissions", :incorrect_usage)
          return
        end
        unless VALID_ACLS.include?(@permissions)
          @cstatus = CliStatus.new("Your permissions '#{@permissions}' are not valid.\nValid settings are: #{VALID_ACLS.join(', ')}", :incorrect_usage)
          return
        end
        @permissions = "pr" if is_public? && @permissions == "r"
        if is_public? && @permissions != "pr"
          @cstatus = CliStatus.new("You may not make an object writable by everyone", :not_supported)
          return
        end
      end

      def is_public?
        return @users.nil?
      end

      def is_valid?
        return @cstatus.is_success?
      end

      def readers
        return @users if @permissions == "r"
        return @users if @permissions == "rw"
        return nil
      end

      def writers
        return @users if @permissions == "w"
        return @users if @permissions == "rw"
        return nil
      end

      def to_s
        return "public-read" if @permissions == "pr"
        return (@permissions + " for " + @users.join(",")) unless @users.nil?
        return @permissions
      end
    end
  end
end
