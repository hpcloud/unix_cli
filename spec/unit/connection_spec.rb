require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include HP::Cloud

describe "Connection options" do
  context "when we create" do
    before(:each) do
      AccountsHelper.use_fixtures()
      ConfigHelper.use_tmp()
      Connection.instance.set_options({})
    end

    def expected_options()
      eopts = HP::Cloud::Config.default_options.clone
      eopts.delete_if{ |k,v| v.nil? }
      return eopts
    end

    it "should have expected values with avail zone" do
      Connection.instance.set_options({:availability_zone=>'somethingelse'})

      options = Connection.instance.create_options(:storage_availability_zone)

      options[:provider].should eq('HP')
      options[:connection_options].should eq(expected_options)
      options[:hp_account_id].should eq('foo')
      options[:hp_secret_key].should eq('bar')
      options[:hp_auth_uri].should eq('http://192.168.1.1:8888/v2.0')
      options[:hp_tenant_id].should eq('111111')
      options[:hp_avl_zone].should eq('somethingelse')
      options[:user_agent].should eq("HPCloud-UnixCLI/#{HP::Cloud::VERSION}")
    end

    it "should have expected values" do
      options = Connection.instance.create_options(:compute_availability_zone)

      options[:provider].should eq('HP')
      options[:connection_options].should eq(expected_options())
      options[:hp_account_id].should eq('foo')
      options[:hp_secret_key].should eq('bar')
      options[:hp_auth_uri].should eq('http://192.168.1.1:8888/v2.0')
      options[:hp_tenant_id].should eq('111111')
      options[:hp_avl_zone].should eq('az-1.region-a.geo-1')
      options[:user_agent].should eq("HPCloud-UnixCLI/#{HP::Cloud::VERSION}")
    end

    it "should have expected values" do
      options = Connection.instance.create_options(:storage_availability_zone)

      options[:provider].should eq('HP')
      options[:connection_options].should eq(expected_options())
      options[:hp_account_id].should eq('foo')
      options[:hp_secret_key].should eq('bar')
      options[:hp_auth_uri].should eq('http://192.168.1.1:8888/v2.0')
      options[:hp_tenant_id].should eq('111111')
      options[:hp_avl_zone].should eq('region-a.geo-1')
      options[:user_agent].should eq("HPCloud-UnixCLI/#{HP::Cloud::VERSION}")
    end

    it "should have expected values" do
      options = Connection.instance.create_options(:block_availability_zone)

      options[:provider].should eq('HP')
      options[:connection_options].should eq(expected_options())
      options[:hp_account_id].should eq('foo')
      options[:hp_secret_key].should eq('bar')
      options[:hp_auth_uri].should eq('http://192.168.1.1:8888/v2.0')
      options[:hp_tenant_id].should eq('111111')
      options[:hp_avl_zone].should eq('az-1.region-a.geo-1')
      options[:user_agent].should eq("HPCloud-UnixCLI/#{HP::Cloud::VERSION}")
    end

    it "should throw exception" do
      directory = Accounts.new.directory
      Connection.instance.set_options({:account_name => 'bogus'})
      lambda {
        Connection.instance.create_options(:storage_availability_zone)
      }.should raise_error(Exception, "Could not find account file: #{directory}bogus")
    end
  end
  after(:all) {reset_all()}
end
