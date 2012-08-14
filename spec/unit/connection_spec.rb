require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Connection options" do
  context "when we create" do
    before(:each) do
      HP::Cloud::Config.set_credentials('default', 'account_id', 'secret_key', 'auth_uri', 'tenant_id')
      HP::Cloud::Config.stub(:settings).and_return({:storage_availability_zone=>'storage_availability'})
      HP::Cloud::Config.stub(:connection_options).and_return({})
    end

    it "should have expected values with avail zone" do
      options = Connection.instance.set_options({:availability_zone=>'somethingelse'})
      options = Connection.instance.create_options('default', :storage_availability_zone)

      options[:provider].should eql('HP')
      options[:connection_options].should eql({})
      options[:hp_account_id].should eql('account_id')
      options[:hp_secret_key].should eql('secret_key')
      options[:hp_auth_uri].should eql('auth_uri')
      options[:hp_tenant_id].should eql('tenant_id')
      options[:hp_avl_zone].should eql('somethingelse')
      options[:user_agent].should eql("HPCloud-UnixCLI/#{HP::Cloud::VERSION}")
    end

    it "should have expected values" do
      options = Connection.instance.create_options('default', :storage_availability_zone)

      options[:provider].should eql('HP')
      options[:connection_options].should eql({})
      options[:hp_account_id].should eql('account_id')
      options[:hp_secret_key].should eql('secret_key')
      options[:hp_auth_uri].should eql('auth_uri')
      options[:hp_tenant_id].should eql('tenant_id')
      options[:hp_avl_zone].should eql('storage_availability')
      options[:user_agent].should eql("HPCloud-UnixCLI/#{HP::Cloud::VERSION}")
    end

    it "should throw exception" do
      lambda { Connection.instance.create_options('bogus', :storage_availability_zone) }.should raise_error(Fog::Storage::HP::Error, "Error getting service credentials. Please check your HP Cloud Services account to make sure the account credentials are correct.")
    end
  end
end
