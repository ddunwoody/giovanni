require File.join(File.dirname(__FILE__), "../lib/utils/helper")

describe Helper do
  before(:each) do
    @helper = Helper.new
  end

  it "should return 'application' if 'url_name' is not defined" do
    @helper.stub!(:fetch).with(:application).and_return('application')
    @helper.stub!(:fetch).with(:url_name, 'application').and_return('application')
    @helper.url_name.should == 'application'
  end

  it "should return 'url_name' if 'url_name' is defined" do
    @helper.stub!(:fetch).with(:application).and_return('application')
    @helper.stub!(:fetch).with(:url_name, 'application').and_return('url_name')
    @helper.url_name.should == 'url_name'
  end
end