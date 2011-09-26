module HP
  module Cloud
    class CLI < Thor
    
      desc 'account:setup', "set up or modify your credentials"
      long_desc <<-DESC
  Setup or modify your account credentials. This is generally the first step
  in the process of using the HP Cloud command-line interface.
  
  You will need your Account ID and Account Key from the HP Cloud web site to
  set up your account. Optionally you can specify your own endpoint to access, 
  but in most cases you will want to use the default.  
  
  You can re-run this command to modify your settings or run account setup for
  storage and compute separately as well.
      DESC
      method_option 'no-validate', :type => :boolean, :default => false,
                    :desc => "Don't verify account settings during setup"
      define_method "account:setup" do
        invoke "account:setup:storage"
        puts ""
        invoke "account:setup:compute"
      end
    
    end
  end
end