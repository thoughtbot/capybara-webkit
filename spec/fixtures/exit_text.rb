require 'spec_helper'
# require 'selenium-webdriver'

RSpec.describe Capybara::Webkit::Driver do
  it "should exit with a zero exit status" do
    browser = Capybara::Webkit::Driver.new(TestApp).browser
    expect(true).to eq(true)
  end
end
