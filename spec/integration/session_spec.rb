# -*- encoding: UTF-8 -*-

require 'spec_helper'
require 'capybara/webkit'

module TestSessions
  Webkit = Capybara::Session.new(:reusable_webkit, TestApp)
end

Capybara::SpecHelper.run_specs TestSessions::Webkit, "webkit"

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

  context "slow iframe app" do
    before do
      @app = Class.new(ExampleApp) do
        get '/' do
          <<-HTML
          <html>
          <head>
          <script>
            function hang() {
              xhr = new XMLHttpRequest();
              xhr.onreadystatechange = function() {
                if(xhr.readyState == 4){
                  document.getElementById('p').innerText = 'finished'
                }
              }
              xhr.open('GET', '/slow', true);
              xhr.send();
              document.getElementById("f").src = '/iframe';
              return false;
            }
          </script>
          </head>
          <body>
            <a href="#" onclick="hang()">Click Me!</a>
            <iframe src="about:blank" id="f"></iframe>
            <p id="p"></p>
          </body>
          </html>
          HTML
        end

        get '/slow' do
          sleep 1
          status 204
        end

        get '/iframe' do
          status 204
        end
      end
    end

    it "should not hang the server" do
      subject.visit("/")
      subject.click_link('Click Me!')
      Capybara.using_wait_time(5) do
        subject.should have_content("finished")
      end
    end
  end

  context "session app" do
    before do
      @app = Class.new(ExampleApp) do
        enable :sessions
        get '/' do
          <<-HTML
          <html>
          <body>
            <form method="post" action="/sign_in">
              <input type="text" name="username">
              <input type="password" name="password">
              <input type="submit" value="Submit">
            </form>
          </body>
          </html>
          HTML
        end

        post '/sign_in' do
          session[:username] = params[:username]
          session[:password] = params[:password]
          redirect '/'
        end

        get '/other' do
          <<-HTML
          <html>
          <body>
            <p>Welcome, #{session[:username]}.</p>
          </body>
          </html>
          HTML
        end
      end
    end

    it "should not start queued commands more than once" do
      subject.visit('/')
      subject.fill_in('username', with: 'admin')
      subject.fill_in('password', with: 'temp4now')
      subject.click_button('Submit')
      subject.visit('/other')
      subject.should have_content('admin')
    end
  end
end
