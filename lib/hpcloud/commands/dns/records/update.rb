module HP
  module Cloud
    class CLI < Thor

      desc "dns:records:update <domain> <name> <type> <data>", "Add a DNS record."
      long_desc <<-DESC
  Add a DNS record to the specified domain with the given name, type and data.

Examples:
  hpcloud dns:records:update mydomain.com. www.mydomain.com A 10.0.0.1 # Create a DNS record for the 'mydomain.com.' domain an 'A' record for 'www.mydomain.com' pointing to 10.0.0.1:
      DESC
      CLI.add_common_options
      define_method "dns:records:update" do |domain, name, type, data|
        cli_command(options) {
          dns = Dnss.new.get(domain)
          unless dns.is_valid?
            @log.fatal dns.cstatus
          end
          record = dns.update_record(name, type, data)
          if record.nil?
            @log.fatal dns.cstatus
          end
          @log.display "Updated DNS record '#{name}' with id '#{record[:id]}'."
        }
      end
    end
  end
end
