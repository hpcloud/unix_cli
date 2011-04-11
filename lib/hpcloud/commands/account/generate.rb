require 'net/ssh'
module HPCloud
  class CLI < Thor
    
    desc 'account:generate <name> <email-address>', "set up or modify your credentials"
    method_option :port, :type => :numeric, :default => Config.settings[:default_port]
    method_option :host, :type => :string, :default => Config.settings[:default_host]
    method_option :login, :type => :string, :default => Config.settings[:keygen_user]
    method_option :password, :type => :string, :default => Config.settings[:keygen_pass]
    define_method "account:generate" do |name, email|
      if options[:login].empty? or options[:password].empty?
        error 'Login and password must be specified to continue.' # would be nice to display help here
      end
      Net::SSH.start(options[:host], options[:login], :password => options[:password]) do |ssh|
        display "logged into #{ssh.exec!('hostname').chomp}..."
        env_variable = 'KVS_TEST_HOST=16.49.184.31'
        keygen = %Q(build/opt-centos5-x86_64/bin/stout-mgr create-account -port #{options[:port]} "#{name}" "#{email}")
        display "Preparing keygen: #{keygen.split('/')[-1]}"
        display ssh.exec!(env_variable && keygen)
      end
    end
    
  end
end