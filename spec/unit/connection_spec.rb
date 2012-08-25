require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include HP::Cloud

describe "Connection options" do
  context "when we create" do
    before(:each) do
      AccountsHelper.use_fixtures()
      ConfigHelper.use_tmp()
    end

    def expected_options()
      eopts = HP::Cloud::Config.default_options.clone
      eopts.delete_if{ |k,v| v.nil? }
      return eopts
    end

    it "should have expected values with avail zone" do
      options = Connection.instance.set_options({:availability_zone=>'somethingelse'})
      options = Connection.instance.create_options('default', :storage_availability_zone)

      options[:provider].should eql('HP')
      options[:connection_options].should eql(expected_options)
      options[:hp_account_id].should eql('foo')
      options[:hp_secret_key].should eql('bar')
      options[:hp_auth_uri].should eql('http://192.168.1.1:8888/v2.0')
      options[:hp_tenant_id].should eql('111111')
      options[:hp_avl_zone].should eql('somethingelse')
      options[:user_agent].should eql("HPCloud-UnixCLI/#{HP::Cloud::VERSION}")
    end

    it "should have expected values" do
      options = Connection.instance.create_options('default', :storage_availability_zone)

      options[:provider].should eql('HP')
      options[:connection_options].should eql(expected_options())
      options[:hp_account_id].should eql('foo')
      options[:hp_secret_key].should eql('bar')
      options[:hp_auth_uri].should eql('http://192.168.1.1:8888/v2.0')
      options[:hp_tenant_id].should eql('111111')
      options[:hp_avl_zone].should eql('region-a.geo-1')
      options[:user_agent].should eql("HPCloud-UnixCLI/#{HP::Cloud::VERSION}")
    end

    it "should throw exception" do
      directory = Accounts.new.directory
      lambda {
        Connection.instance.create_options('bogus', :storage_availability_zone)
      }.should raise_error(Exception, "Could not find account file: #{directory}bogus")
    end

    after(:each) do
    end
  end
end
