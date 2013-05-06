module HP
  module Cloud
    class CLI < Thor

      desc "dns:update <name>", "Update a DNS domain."
      long_desc <<-DESC
  Update a DNS domain with the specified name.  Optionally, you can specify an email or a time to live (TTL) to adjust DNS caching for your entry.  The default TTL is 3600 (one hour).

Examples:
  hpcloud dns:update mydomain.com. email@example.com        # Create a new DNS domain `mydomain.com` with email address `email@example.com`:
  hpcloud dns:update mydomain.com. email@xample.com -t 7200 # Create a new DNS domain `mydomain.com` with email address `email@example.com` and TTL 7200:
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
