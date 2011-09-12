# -*- encoding: UTF-8 -*-

require 'spec_helper'
require 'capybara-webkit'

describe Capybara::Session do
  subject { Capybara::Session.new(:reusable_webkit, @app) }
  after { subject.reset! }

  context "slow javascript app" do
    before(:all) do
      @app = lambda do |env|
        body = <<-HTML
          <html><body>
            <form action="/next" id="submit_me"><input type="submit" value="Submit" /></form>
            <p id="change_me">Hello</p>

            <script type="text/javascript">
              var form = document.getElementById('submit_me');
              form.addEventListener("submit", function (event) {
                event.preventDefault();
                setTimeout(function () {
                  document.getElementById("change_me").innerHTML = 'Good' + 'bye';
                }, 500);
              });
            </script>
          </body></html>
        HTML
        [200,
          { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
          [body]]
      end
    end

    before do
      @default_wait_time = Capybara.default_wait_time
      Capybara.default_wait_time = 1
    end

    after { Capybara.default_wait_time = @default_wait_time }

    it "waits for a request to load" do
      subject.visit("/")
      subject.find_button("Submit").click
      subject.should have_content("Goodbye");
    end
  end

  context "simple app" do
    before(:all) do
      @app = lambda do |env|
        body = <<-HTML
          <html><body>
            <strong>Hello</strong>
            <span>UTF8文字列</span>
            <input type="button" value="ボタン" />
          </body></html>
        HTML
        [200,
          { 'Content-Type' => 'text/html; charset=UTF-8', 'Content-Length' => body.length.to_s },
          [body]]
      end
    end

    before do
      subject.visit("/")
    end

    it "inspects nodes" do
      subject.all(:xpath, "//strong").first.inspect.should include("strong")
    end

    it "can read utf8 string" do
      utf8str = subject.all(:xpath, "//span").first.text
      utf8str.should eq('UTF8文字列')
    end

    it "can click utf8 string" do
      subject.click_button('ボタン')
    end
  end

  context "response headers with status code" do
    before(:all) do
      @app = lambda do |env|
        params = ::Rack::Utils.parse_query(env['QUERY_STRING'])
        if params["img"] == "true"
          body = 'not found'
          return [404, { 'Content-Type' => 'image/gif', 'Content-Length' => body.length.to_s }, [body]]
        end
        body = <<-HTML
          <html>
            <body>
              <img src="?img=true">
            </body>
          </html>
        HTML
        [200,
          { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s, 'X-Capybara' => 'WebKit'},
          [body]]
      end
    end

    it "should get status code" do
      subject.visit '/'
      subject.status_code.should == 200
    end

    it "should reset status code" do
      subject.visit '/'
      subject.status_code.should == 200
      subject.reset!
      subject.status_code.should == 0
    end

    it "should get response headers" do
      subject.visit '/'
      subject.response_headers['X-Capybara'].should == 'WebKit'
    end

    it "should reset response headers" do
      subject.visit '/'
      subject.response_headers['X-Capybara'].should == 'WebKit'
      subject.reset!
      subject.response_headers['X-Capybara'].should == nil
    end
  end

  context "cookie-based app" do
    before(:all) do
      @cookie = 'cookie=abc; domain=127.0.0.1; path=/'
      @app = lambda do |env|
        request = ::Rack::Request.new(env)

        body = <<-HTML
          <html><body>
            <p id="cookie">#{request.cookies["cookie"] || ""}</p>
          </body></html>
        HTML
        [200,
          { 'Content-Type'   => 'text/html; charset=UTF-8',
            'Content-Length' => body.length.to_s,
            'Set-Cookie'     => @cookie,
          },
          [body]]
      end
    end

    def echoed_cookie
      subject.all(:css, "#cookie").first.text
    end

    it "should remember the cookie on second visit" do
      subject.visit "/"
      echoed_cookie.should == ""
      subject.visit "/"
      echoed_cookie.should == "abc"
    end

    it "should use the custom cookie" do
      $webkit_browser.set_cookie @cookie
      subject.visit "/"
      echoed_cookie.should == "abc"
    end

    it "should clear cookies" do
      subject.visit "/"
      $webkit_browser.clear_cookies
      subject.visit "/"
      echoed_cookie.should == ""
    end

    it "should get cookies" do
      subject.visit "/"
      cookies = $webkit_browser.get_cookies

      cookies.size.should == 1

      cookie = Hash[cookies[0].split(/\s*;\s*/)
                              .map { |x| x.split("=", 2) }]
      cookie["cookie"].should == "abc"
      cookie["domain"].should include "127.0.0.1"
      cookie["path"].should == "/"
    end
  end
end

describe Capybara::Session, "with TestApp" do
  before do
    @session = Capybara::Session.new(:reusable_webkit, TestApp)
  end

  it_should_behave_like "session"
  it_should_behave_like "session with javascript support"
end
