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

  context "custom HTML" do
    before(:all) do
      @requested = []
      @app = lambda do |env|
        params = ::Rack::Utils.parse_query(env['QUERY_STRING'])

        type = params["get"]
        @requested << type
        if type == "javascript"
          js = <<-JS
            onload_handler = function() {
              document.getElementById("url").innerHTML = document.location;
            }
          JS
          [200,
            { 'Content-Type'   => 'text/javascript; charset=UTF-8',
              'Content-Length' => js.size.to_s,
            }, [js]]
        else
          [200,
            { 'Content-Type'   => 'text/%s; charset=UTF-8' % type,
              'Content-Length' => "0",
            }, [""]]
        end
      end
    end

    before do
      @requested.clear
      @root_url = subject.driver.send(:url, "/")
    end

    def set_html(url = @root_url)
      $webkit_browser.set_html <<-HTML, url
        <html>
          <head>
            <title>Test</title>
            <script type="text/javascript" src="?get=javascript"></script>
            <link rel="stylesheet" type="text/css" href="?get=css" />
          </head>
          <body onload="onload_handler();">
            <p id="welcome">Hello</p>
            <p id="url">n/a</p>
          </body>
        </html>
      HTML
      subject.all(:css, "#welcome").first.text.should == "Hello"
    end

    it "should allow setting custom HTML without URL" do
      set_html nil
    end

    it "should allow setting custom HTML with URL" do
      set_html
      $webkit_browser.url.should == @root_url
    end

    it "should load resources from right location" do
      set_html
      @requested.size.should == 2
      @requested.should include "javascript"
      @requested.should include "css"
    end

    it "should make fake URL accessible through document.location" do
      set_html
      subject.all(:css, "#url").first.text.should == @root_url
    end
  end

  context 'special HTML loading attributes' do
    before(:all) do
      @requested = []
      @app = lambda do |env|
        params = ::Rack::Utils.parse_query(env['QUERY_STRING'])

        type = params["get"]
        @requested << type if type
        if type == "image"
          [200,
            { 'Content-Type'   => 'image/jpeg',
              'Content-Length' => "0",
            }, [""]]
        else
          body = <<-HTML
            <html>
              <head>
                <title>Test</title>
              </head>
              <body onload="onload_handler();">
                <p id="welcome">Hello</p>
                <img src="?get=image" />
              </body>
            </html>
          HTML

          [200,
            { 'Content-Type'   => 'text/html',
              'Content-Length' => body.size.to_s,
            }, [body]]
        end
      end
    end

    before do
      @requested.clear
    end

    it 'should respect AutoLoadImages = false' do
      $webkit_browser.set_attribute("AutoLoadImages", false)
      subject.visit "/"
      @requested.size.should == 0
    end

    it 'should reset AutoLoadImages when requested explicitly' do
      $webkit_browser.set_attribute("AutoLoadImages", false)
      subject.visit "/"
      $webkit_browser.reset_attribute("AutoLoadImages")
      subject.visit "/"
      @requested.should include "image"
    end

    it 'should reset AutoLoadImages automatically on driver reset' do
      $webkit_browser.set_attribute("AutoLoadImages", false)
      subject.visit "/"
      subject.reset!
      subject.visit "/"
      @requested.should include "image"
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
