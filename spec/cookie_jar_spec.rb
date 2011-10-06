require 'spec_helper'
require 'capybara/driver/webkit/cookie_jar'

describe Capybara::Driver::Webkit::CookieJar do
  let(:browser) {
    browser = double("Browser")
    browser.stub(:get_cookies) { [
        "cookie1=1; domain=.example.org; path=/",
        "cookie1=2; domain=.example.org; path=/dir1/",
        "cookie1=3; domain=.facebook.com; path=/",
        "cookie2=4; domain=.sub1.example.org; path=/",
      ] }
    browser
  }

  subject { Capybara::Driver::Webkit::CookieJar.new(browser) }

  describe "#[]" do
    it "should return the right cookie value for every given domain/path" do
      subject["cookie1", "example.org"].should == "1"
      subject["cookie1", "www.facebook.com"].should == "3"
      subject["cookie2", "sub1.example.org"].should == "4"
    end

    it "should not return cookie from other domain" do
      subject["cookie2", "www.example.org"].should == nil
    end

    it "should handle path precedence correctly" do
      subject["cookie1", "www.example.org"].should == "1"
      subject["cookie1", "www.example.org", "/dir1/123"].should == "2"
    end
  end
end
