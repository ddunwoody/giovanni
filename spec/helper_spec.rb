require File.join(File.dirname(__FILE__), "../lib/utils/helper")

describe Helper do
  before(:each) do
    @helper = Helper.new
    @helper.stub!(:fetch).and_return("foo")    
  end

  it "should get url" do
    @helper.url_name.should == 'foo'
  end
end