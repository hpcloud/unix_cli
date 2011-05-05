require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "account:setup command" do
  
  before(:all) { setup_temp_home_directory }
  
  context "without existing account" do
  
    it "should ask for email address"
    
    it "should ask for account id"
    
    it "should ask for secret key"
    
    it "should provide option to set endpoint"
    
    it "should provide default endpoint"
    
    it "should validate account" do
      
    end
    
    context "when successful" do
      
      it "should create account credential file"
      
    end
       
  end
  
  pending 'with existing account' do
  end
  
end