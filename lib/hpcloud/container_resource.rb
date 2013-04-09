require 'hpcloud/remote_resource.rb'

module HP
  module Cloud
    class ContainerResource < RemoteResource
      attr_accessor :count

      def parse
        unless @fname.index('/').nil?
          raise Exception.new("Valid container names do not contain the '/' character: #{@fname}")
        end
        @fname = ':' + @fname  if @fname[0,1] != ':'
        super
        @lname = @fname
        @sname = @container
      end

      def valid_virtualhost?
        return false if @container.nil?
        if (1..63).include?(@container.length)
          if @container =~ /^[a-z0-9-]*$/
            if @container[0,1] != '-' and @container[-1,1] != '-'
              return true 
            end
          end
        end
        false
      end

      def head
        return container_head()
      end

      def cdn_public_url
        @storage.directories.head(@container).cdn_public_url
      end

      def cdn_public_ssl_url
        @storage.directories.head(@container).cdn_public_ssl_url
      end

      def remove(force, at=nil, after=nil)
        begin
          return false unless container_head()
          unless at.nil?
            @cstatus = CliStatus.new("The at option is only supported for objects.", :incorrect_usage)
            return false
          end
          unless after.nil?
            @cstatus = CliStatus.new("The after option is only supported for objects.", :incorrect_usage)
            return false
          end

          if force == true
            foreach { |x| x.remove(force) }
          end
          begin
            @storage.delete_container(@container)
          rescue Excon::Errors::Conflict
            @cstatus = CliStatus.new("The container '#{@fname}' is not empty. Please use -f option to force deleting a container with objects in it.", :conflicted)
            return false
          end
        rescue Excon::Errors::Forbidden => error
          @cstatus = CliStatus.new("Permission denied for '#{@fname}.", :permission_denied)
          return false
        rescue Exception => e
          @cstatus = CliStatus.new("Exception removing '#{@fname}': " + e.to_s, :general_error)
          return false
        end
        return true
      end

      def tempurl(period)
        @cstatus = CliStatus.new("Temporary URLs not supported on containers ':#{@container}'.", :incorrect_usage)
        return nil
      end

      def grant(acl)
        begin
          return false unless container_head()

          @readacl.grant(acl.readers)
          @writeacl.grant(acl.writers)
          return save()
        rescue Exception => e
          @cstatus = CliStatus.new("Exception granting permissions for '#{@fname}': " + e.to_s, :general_error)
          return false
        end
      end

      def revoke(acl)
        begin
          return false unless container_head()

          @readacl.revoke(acl.readers)
          @writeacl.revoke(acl.writers)
          return save()
        rescue Exception => e
          @cstatus = CliStatus.new("Exception revoking permissions for '#{@fname}': " + e.to_s, :general_error)
          return false
        end
      end

      def sync(synckey, syncto)
        return false unless container_head()
        @synckey = synckey
        @syncto = syncto
        return save
      end

      def save
        options = {}
        options['X-Container-Sync-Key'] = @synckey unless @synckey.nil?
        options['X-Container-Sync-To'] = @syncto unless @syncto.nil?
        options.merge!(@readacl.to_hash)
        options.merge!(@writeacl.to_hash)
        begin
          @storage.put_container(@container, options)
        rescue Excon::Errors::BadRequest => error
          @@error = ErrorResponse.new(error).to_s
          error_status = :incorrect_usage
        end
        return true
      end
    end
  end
end
