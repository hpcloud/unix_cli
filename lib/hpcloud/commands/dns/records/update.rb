module HP
  module Cloud
    class CLI < Thor

      desc "dns:records:update <domain> <name> <type> <data>", "Update a DNS record."
      long_desc <<-DESC
  Update a DNS record to the specified domain with the given name, type and data.

Examples:
  hpcloud dns:records:update mydomain.com. www.mydomain.com A 10.0.0.1 # Create a DNS record for domain `mydomain.com` and record `A` for `www.mydomain.com` pointing to address 10.0.0.1:
      DESC
      CLI.add_common_options
      define_method "dns:records:update" do |domain, name, type, data|
        cli_command(options) {
          dns = Dnss.new.get(domain)
          unless dns.is_valid?
            @log.fatal dns.cstatus
          end
          record = dns.update_record(name, type, data)
          unless record.nil?
            @log.display "Updated DNS record '#{name}' with id '#{record[:id]}'."
          else
            @log.error "Cannot find DNS record '#{name}'."
          end
        }
      end
    end
  end
end
