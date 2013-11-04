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

      desc "dns:update <name>", "Update a DNS domain."
      long_desc <<-DESC
  Update a DNS domain with the specified name.  Optionally, you can specify an email or a time to live (TTL) to adjust DNS caching for your entry.  The default TTL is 3600 (one hour).

Examples:
  hpcloud dns:update mydomain.com. -e email@example.com        # Update DNS domain `mydomain.com` with email address `email@example.com`
  hpcloud dns:update mydomain.com. -e email@xample.com -t 7200 # Update DNS domain `mydomain.com` with email address `email@example.com` and TTL 7200
      DESC
      method_option :email,
                    :type => :string, :aliases => '-e',
                    :desc => 'Email address.'
      method_option :ttl,
                    :type => :string, :aliases => '-t',
                    :desc => 'Time to live.'
      CLI.add_common_options
      define_method "dns:update" do |name|
        cli_command(options) {
          dns = Dnss.new.get(name)
          if dns.is_valid? == false
            @log.fatal dns.cstatus
          end
          dns.ttl = options[:ttl] unless options[:ttl].nil?
          dns.email = options[:email] unless options[:email].nil?
          if dns.save == true
            @log.display "Updated DNS domain '#{name}'."
          else
            @log.fatal dns.cstatus
          end
        }
      end
    end
  end
end
