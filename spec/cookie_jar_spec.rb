require 'spec_helper'
require 'capybara/webkit/cookie_jar'

describe Capybara::Webkit::CookieJar do
  let(:browser) {
    browser = double("Browser")
    allow(browser).to receive(:get_cookies) { [
        "cookie1=1; domain=.example.org; path=/",
        "cookie1=2; domain=.example.org; path=/dir1/",
        "cookie1=3; domain=.facebook.com; path=/",
        "cookie2=4; domain=.sub1.example.org; path=/",
      ] }
    browser
  }

  subject { Capybara::Webkit::CookieJar.new(browser) }

  describe "#find" do
    it "returns a cookie object" do
      expect(subject.find("cookie1", "www.facebook.com").domain).to eq ".facebook.com"
    end

    it "returns the right cookie for every given domain/path" do
      expect(subject.find("cookie1", "example.org").value).to eq "1"
      expect(subject.find("cookie1", "www.facebook.com").value).to eq "3"
      expect(subject.find("cookie2", "sub1.example.org").value).to eq "4"
    end

    it "does not return a cookie from other domain" do
      expect(subject.find("cookie2", "www.example.org")).to eq nil
    end

    it "respects path precedence rules" do
      expect(subject.find("cookie1", "www.example.org").value).to eq "1"
      expect(subject.find("cookie1", "www.example.org", "/dir1/123").value).to eq "2"
    end
  end

  describe "#[]" do
    it "returns the first matching cookie's value" do
      expect(subject["cookie1", "example.org"]).to eq "1"
    end

    it "returns nil if no cookie is found" do
      expect(subject["notexisting"]).to eq nil
    end
  end
end
