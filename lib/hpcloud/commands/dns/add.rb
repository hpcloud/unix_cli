module HP
  module Cloud
    class CLI < Thor

      desc "dns:add <name> <email>", "Add a DNS domain."
      long_desc <<-DESC
  Add a DNS domain with the specified name and email address.  Optionally, you can specify a TTL (time to live) to adjust DNS caching of your entry.  The default time to live (TTL) is 3600 (one hour).

Examples:
  hpcloud dns:add mydomain.com. email@example.com        # Create a new DNS domain `mydomain.com` with email address `email@example.com`:
  hpcloud dns:add mydomain.com. email@xample.com -t 7200 # Create a new DNS domain `mydomain.com` with email address `email@example.com` and time to live 7200:
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
