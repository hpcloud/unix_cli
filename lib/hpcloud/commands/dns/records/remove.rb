module HP
  module Cloud
    class CLI < Thor

      desc "dns:records:remove <domain> <name ...>", "Remove a DNS record."
      long_desc <<-DESC
  Remove a DNS record to the specified domain.  Records may be specified by name or ID.

Examples:
  hpcloud dns:records:remove mydomain.com. www.mydomain.com # Remove record `www.mydomain.com` from the domain `mydomain.com`.
      DESC
      CLI.add_common_options
      define_method "dns:records:remove" do |domain, *names|
        cli_command(options) {
          dns = Dnss.new.get(domain)
          unless dns.is_valid?
            @log.fatal dns.cstatus
          end
          names.each { |name|
            sub_command("removing DNS record") {
              if dns.delete_record(name)
                @log.display "Removed DNS record '#{name}'."
              else
                @log.error "Cannot find DNS record '#{name}'."
              end
            }
          }
        }
      end
    end
  end
end
