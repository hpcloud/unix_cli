require 'hpcloud/rules'
require 'hpcloud/commands/securitygroups/rules/add'
require 'hpcloud/commands/securitygroups/rules/remove'

module HP
  module Cloud
    class CLI < Thor

      map 'securitygroups:rules:list' => 'securitygroups:rules'

      desc "securitygroups:rules <sec_group_name>", "list of rules for a security group"
      long_desc <<-DESC
  List the rules for a security group for your compute account.

Examples:
  hpcloud securitygroups:rules mysecgroup

Aliases: securitygroups:rules:list
      DESC
      define_method "securitygroups:rules" do |sec_group_name|
        begin
          compute_connection = connection(:compute)
          security_group = compute_connection.security_groups.select {|sg| sg.name == sec_group_name}.first
          if (security_group && security_group.name == sec_group_name)
            rules = security_group.rules
            if rules.empty?
              display "You currently have no rules for the security group '#{sec_group_name}'."
            else
              Rules.table(rules)
            end
          else
            error "You don't have a security group '#{sec_group_name}'.", :not_found
          end
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          display_error_message(error)
        end
      end

    end
  end
end