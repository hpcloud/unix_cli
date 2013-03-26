module HP
  module Cloud
    class Acl
      ALL = ".r:*,.rlistings"

      attr_reader :cstatus, :public, :users

      def initialize(key, hash)
        @key = key
        @cstatus = CliStatus.new
        hash = {} if hash.nil?
        @users = parse_acl(hash[key])
        @public = parse_public(hash[key])
      end

      def parse_acl(header)
        return nil if header.nil?
        return [] if header.start_with?(".r:*")
        ray = []
        header.split(",").each {|x|
           if x.index(":")
             u = x.split(":")[1]
             ray << u unless u.nil?
           else
             ray << x
           end
        }
        return nil if ray.empty?
        return ray
      end

      def parse_public(header)
        return "no" if header.nil?
        return header.start_with?(".r:*")?"yes":"no"
      end

      def is_valid?
        return @cstatus.is_success?
      end

      def to_hash
        return { @key => '' } if @users.nil?
        return { @key => ALL } if @users.empty?
        return { @key => "*:" + @users.join(",*:") }
      end

      def grant(ray)
        return true if ray.nil?
        return true if ray.empty?
        @users = [] if @users.nil?
        ray.each{ |x|
          @users << x unless @users.index(x)
        }
        return true
      end

      def revoke(ray)
        return true if ray.nil?
        return true if ray.empty?
        not_found = []
        if @users.nil?
          not_found << ray
        else
          ray.each{ |x|
            if @users.delete(x).nil?
              rc = false
              not_found << x
            end
          }
        end
        @users = nil if @users.nil? || @users.empty?
        return true if not_found.empty?
        @cstatus = CliStatus.new("Revoke failed invalid user: #{not_found.join(',')}", :not_found)
        return false
      end
    end

    class AclReader < Acl
      KEY = 'X-Container-Read'
      def initialize(hash)
        super(KEY, hash)
      end
    end

    class AclWriter < Acl
      KEY = 'X-Container-Write'
      def initialize(hash)
        super(KEY, hash)
      end
    end
  end
end
