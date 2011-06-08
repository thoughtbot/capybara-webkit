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
  context "custom header" do
    before(:all) do
      @app = lambda do |env|
        body = <<-HTML
          <html><body>
            <pre>#{env['HTTP_USER_AGENT']}</pre>
            <pre>#{env['HTTP_X_CAPYBARA_WEBKIT_HEADER']}</pre>
            <pre>#{env['HTTP_ACCEPT']}</pre>
            <a href="/">/</a>
          </body></html>
        HTML
        [200,
          { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
          [body]]
      end
    end

    it "can set user_agent" do
      subject.driver.header('user-agent', 'capybara-webkit/custom-user-agent')
      subject.visit('/')
      subject.should have_content('capybara-webkit/custom-user-agent')
      subject.should be_true subject.driver.evaluate_script('navigator.userAgent').eql?('capybara-webkit/custom-user-agent')
    end

    it "reset default user_agent" do
      subject.visit('/')
      subject.should have_content('Mozilla/5.0')
      subject.should be_true subject.driver.evaluate_script('navigator.userAgent').start_with?('Mozilla/5.0')
    end
    it "keep user_agent in next page" do
      subject.driver.header('user-agent', 'capybara-webkit/custom-user-agent')
      subject.visit('/')
      subject.click_link('/')
      subject.should have_content('capybara-webkit/custom-user-agent')
      subject.should be_true subject.evaluate_script('navigator.userAgent').eql?('capybara-webkit/custom-user-agent')
    end

    it "can set custom header" do
      subject.driver.header('x-capybara-webkit-header', 'x-capybara-webkit-spec')
      subject.visit('/')
      subject.should have_content('x-capybara-webkit-spec')
    end

    it "does not keep custom header" do
      subject.visit('/')
      subject.should_not have_content('x-capybara-webkit-spec')
    end

    it "can set Accept" do
      subject.driver.header('accept', 'application/xhtml+xml')
      subject.visit('/')
      subject.should have_content('application/xhtml+xml')
    end
  end

end

describe Capybara::Session, "with TestApp" do
  before do
    @session = Capybara::Session.new(:reusable_webkit, TestApp)
  end

  # it_should_behave_like "session"
  # it_should_behave_like "session with javascript support"
end
