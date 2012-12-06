require 'hpcloud/accounts'

module HP
  module Cloud
    class CLI < Thor

      desc 'account:setup <account_name>', "Create or edit your account credentials."
      long_desc <<-DESC
See account:edit
      DESC
      method_option 'no-validate', :type => :boolean, :aliases => '-n',
                    :default => false,
                    :desc => "Don't verify account settings during edit"
      define_method "account:setup" do |*args|
        send("account:edit", args)
      end
    end
  end
end
