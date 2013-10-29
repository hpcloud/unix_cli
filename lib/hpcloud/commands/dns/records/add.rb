module HP
  module Cloud
    class CLI < Thor

      desc "dns:records:add <domain> <name> <type> <data> [priority]", "Add a DNS record."
      long_desc <<-DESC
  Add a DNS record to the specified domain with the given name, type and data.  Optionally, a priority may be added.

Examples:
  hpcloud dns:records:add mydomain.com. www.mydomain.com. A 10.0.0.1 # Create a DNS record for domain `mydomain.com` and `A` record for `www.mydomain.com` pointing to address 10.0.0.1.
      DESC
      CLI.add_common_options
      define_method "dns:records:add" do |domain, name, type, data, *priority|
        cli_command(options) {
          dns = Dnss.new.get(domain)
          unless dns.is_valid?
            @log.fatal dns.cstatus
          end
          priority = priority[0]
          record = dns.create_record(name, type, data, { 'priority' => priority.to_i })
          if record.nil?
            @log.fatal dns.cstatus
          end
          @log.display "Created dns record '#{name}' with id '#{record[:id]}'."
        }
      end
    end
  end
end
