module HPCloud
  class CLI < Thor
    
    desc 'account:setup', "set up or modify your credentials"
    define_method "account:setup" do
      credentials = {}
      credentials[:email] = ask 'Account email address:'
      credentials[:access_id] = ask 'Access ID:'
      credentials[:secret_key] = ask 'Secret key:'
      credentials[:host] = ask_with_default 'Host:', '16.49.184.31'
      credentials[:port] = ask_with_default 'Port:', 9232
      Config.update_credentials :default, credentials
      puts "Account credentials have been set up."
    end
    
  end
end