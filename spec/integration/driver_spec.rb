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

  it "returns the rack server port" do
    @driver.server_port.should  eq(@driver.instance_variable_get(:@rack_server).port)
  end

end
