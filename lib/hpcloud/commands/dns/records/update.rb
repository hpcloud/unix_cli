module HP
  module Cloud
    class CLI < Thor

      desc "dns:records:update <domain> <id> <type> <data>", "Update a DNS record."
      long_desc <<-DESC
  Update a DNS record to the specified domain with the given id, type and data.

Examples:
  hpcloud dns:records:update mydomain.com. www.mydomain.com. A 10.0.0.1 # Update a DNS domain `mydomain.com` record `A` for `www.mydomain.com` pointing to address 10.0.0.1
      DESC
      CLI.add_common_options
      define_method "dns:records:update" do |domain, id, type, data|
        cli_command(options) {
          dns = Dnss.new.get(domain)
          unless dns.is_valid?
            @log.fatal dns.cstatus
          end
          record = dns.update_record(id, type, data)
          unless record.nil?
            @log.display "Updated DNS record '#{id}'."
          else
            @log.error "Cannot find DNS record '#{id}'."
          end
        }
      end
    end
  end
end
