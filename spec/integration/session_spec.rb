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
end

describe Capybara::Session, "with TestApp" do
  before do
    @session = Capybara::Session.new(:reusable_webkit, TestApp)
  end

  # def extract_results(session)
  #   YAML.load Nokogiri::HTML(session.body).xpath("//pre[@id='results']").first.text
  # end

  # it_should_behave_like 'attach_file'
  it_should_behave_like "session"
  # it_should_behave_like "session with javascript support"
end
