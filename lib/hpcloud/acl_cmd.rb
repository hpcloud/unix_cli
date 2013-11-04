# encoding: utf-8
#
# © Copyright 2013 Hewlett-Packard Development Company, L.P.
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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
        @users = users

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
        return false if @users.nil?
        return true if @users.empty?
        return false
      end

      def is_valid?
        return @cstatus.is_success?
      end

      def readers
        return [] if @permissions == "pr"
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
