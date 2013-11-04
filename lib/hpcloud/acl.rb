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
        return { } if @users.nil?
        return { @key => ALL } if @users.empty?
        return { @key => "*:" + @users.join(",*:") }
      end

      def grant(ray)
        return true if ray.nil?
        @users = ray
        return true
      end

      def revoke(ray)
        if ray.nil?
          @users = nil
          return true
        end
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
