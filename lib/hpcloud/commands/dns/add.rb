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
    class CLI < Thor

      desc "dns:add <name> <email>", "Add a DNS domain."
      long_desc <<-DESC
  Add a DNS domain with the specified name and email address.  Optionally, you can specify a TTL (time to live) to adjust DNS caching of your entry.  The default time to live (TTL) is 3600 (one hour).

Examples:
  hpcloud dns:add mydomain.com. email@example.com        # Create a new DNS domain `mydomain.com` with email address `email@example.com`
  hpcloud dns:add mydomain.com. email@xample.com -t 7200 # Create a new DNS domain `mydomain.com` with email address `email@example.com` and time to live 7200
      DESC
      method_option :ttl, :default => 3600,
                    :type => :string, :aliases => '-t',
                    :desc => 'Time to live.'
      CLI.add_common_options
      define_method "dns:add" do |name, email|
        cli_command(options) {
          if Dnss.new.get(name).is_valid? == true
            @log.fatal "Dns with the name '#{name}' already exists"
          end
          dns = HP::Cloud::DnsHelper.new(Connection.instance)
          dns.name = name
          dns.ttl = options[:ttl]
          dns.email = email
          if dns.save == true
            @log.display "Created dns '#{name}' with id '#{dns.id}'."
          else
            @log.fatal dns.cstatus
          end
        }
      end
    end
  end
end
