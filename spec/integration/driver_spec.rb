require 'spec_helper'
require 'capybara/driver/webkit'

describe Capybara::Driver::Webkit do
  before do
    @driver = Capybara::Driver::Webkit.new(TestApp, :browser => $webkit_browser)
  end

  it_should_behave_like "driver"
  it_should_behave_like "driver with javascript support"
  it_should_behave_like "driver with cookies support"
  it_should_behave_like "driver with header support"
  it_should_behave_like "driver with status code support"
  it_should_behave_like "driver with frame support"
  it_should_behave_like "driver with support for window switching"

  it "returns the rack server port" do
    @driver.visit '/'
    @driver.server_port.should == @driver.browser.current_url[%r{(\d+)/$},1].to_i
  end

  it "returns the rack server host" do
    @driver.visit '/'
    @driver.server_host.should == @driver.browser.current_url[%r{http://([^:]*):},1]
  end
end
