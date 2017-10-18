# -*- encoding: UTF-8 -*-

require 'spec_helper'
require 'capybara/webkit'

module TestSessions
  Webkit = Capybara::Session.new(:reusable_webkit, TestApp)
end

Capybara::SpecHelper.run_specs TestSessions::Webkit, "webkit"

describe Capybara::Session do
  include AppRunner
  include Capybara::RSpecMatchers

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

    around do |example|
      Capybara.using_wait_time(1) do
        example.run
      end
    end

    it "waits for a request to load" do
      subject.visit("/")
      subject.find_button("Submit").click
      expect(subject).to have_content("Goodbye");
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
            <a href="about:blank">Link</a>
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
      expect(subject.all(:xpath, "//strong").first.inspect).to include("strong")
    end

    it "can read utf8 string" do
      utf8str = subject.all(:xpath, "//span").first.text
      expect(utf8str).to eq('UTF8文字列')
    end

    it "can click utf8 string" do
      subject.click_button('ボタン')
    end

    it "raises an ElementNotFound error when the selector scope is no longer valid" do
      subject.within('//body') do
        subject.click_link 'Link'
        expect { subject.find('//strong') }.to raise_error(Capybara::ElementNotFound)
      end
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
      expect(subject.status_code).to eq 200
    end

    it "should reset status code" do
      subject.visit '/'
      expect(subject.status_code).to eq 200
      subject.reset!
      expect(subject.status_code).to eq 0
    end

    it "should get response headers" do
      subject.visit '/'
      expect(subject.response_headers['X-Capybara']).to eq 'WebKit'
    end

    it "should reset response headers" do
      subject.visit '/'
      expect(subject.response_headers['X-Capybara']).to eq 'WebKit'
      subject.reset!
      expect(subject.response_headers['X-Capybara']).to eq nil
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
        expect(subject).to have_content("finished")
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
      expect(subject).to have_content('admin')
    end
  end

  context "iframe app" do
    before(:all) do
      @app = Class.new(ExampleApp) do
        get '/' do
          <<-HTML
            <!DOCTYPE html>
            <html>
            <body>
              <h1>Main Frame</h1>
              <iframe src="/a" name="a_frame" width="500" height="500"></iframe>
            </body>
            </html>
          HTML
        end

        get '/a' do
          <<-HTML
            <!DOCTYPE html>
            <html>
            <body>
              <h1>Page A</h1>
              <iframe src="/b" name="b_frame" width="500" height="500"></iframe>
            </body>
            </html>
          HTML
        end

        get '/b' do
          <<-HTML
            <!DOCTYPE html>
            <html>
            <body>
              <h1>Page B</h1>
              <form action="/c" method="post">
              <input id="button" name="commit" type="submit" value="B Button">
              </form>
            </body>
            </html>
          HTML
        end

        post '/c' do
          <<-HTML
            <!DOCTYPE html>
            <html>
            <body>
              <h1>Page C</h1>
            </body>
            </html>
          HTML
        end
      end
    end

    it 'supports clicking an element offset from the viewport origin' do
      subject.visit '/'

      subject.within_frame 'a_frame' do
        subject.within_frame 'b_frame' do
          subject.click_button 'B Button'
          expect(subject).to have_content('Page C')
        end
      end
    end

    it 'raises an error if an element is obscured when clicked' do
      subject.visit('/')

      subject.execute_script(<<-JS)
        var div = document.createElement('div');
        div.style.position = 'absolute';
        div.style.left = '0px';
        div.style.top = '0px';
        div.style.width = '100%';
        div.style.height = '100%';
        document.body.appendChild(div);
      JS

      subject.within_frame('a_frame') do
        subject.within_frame('b_frame') do
          expect {
            subject.click_button 'B Button'
          }.to raise_error(Capybara::Webkit::ClickFailed)
        end
      end
    end

    it "can swap to the same frame multiple times" do
      subject.visit("/")
      subject.within_frame("a_frame") do
        expect(subject).to have_content("Page A")
      end
      subject.within_frame("a_frame") do
        expect(subject).to have_content("Page A")
      end
    end
  end

  context "text" do
    before(:all) do
      @app = Class.new(ExampleApp) do
        get "/" do
          <<-HTML
            <!DOCTYPE html>
            <html>
            <head></head>
            <body>
              <form>
                This is my form
                <input name="type"/>
                <input name="tagName"/>
              </form>
            </body>
            </html>
          HTML
        end
      end
    end

    it "gets a forms text when inputs have conflicting names" do
      subject.visit("/")
      expect(subject.find(:css, "form").text).to eq("This is my form")
    end
  end

  context 'click tests' do
    before(:all) do
      @app = Class.new(ExampleApp) do
        get '/' do
          <<-HTML
            <!DOCTYPE html>
            <html>
            <head>
            <style>
              body {
                width: 800px;
                margin: 0;
              }
              .target {
                width: 200px;
                height: 200px;
                float: left;
                margin: 100px;
              }
              #offscreen {
                position: absolute;
                left: -5000px;
              }
            </style>
            <body>
              <div id="one" class="target"></div>
              <div id="two" class="target"></div>
              <div id="offscreen"><a href="/" id="foo">Click Me</a></div>
              <form>
                <input type="checkbox" id="bar">
              </form>
              <div><a href="#"><i></i>Some link</a></div>
              <script type="text/javascript">
                var targets = document.getElementsByClassName('target');
                for (var i = 0; i < targets.length; i++) {
                  var target = targets[i];
                  target.onclick = function(event) {
                    this.setAttribute('data-click-x', event.clientX);
                    this.setAttribute('data-click-y', event.clientY);
                  };
                }
              </script>
            </body>
            </html>
          HTML
        end
      end
    end

    it 'clicks in the center of an element' do
      subject.visit('/')
      subject.find(:css, '#one').click
      expect(subject.find(:css, '#one')['data-click-x']).to eq '199'
      expect(subject.find(:css, '#one')['data-click-y']).to eq '199'
    end

    it 'clicks in the center of the viewable area of an element' do
      subject.visit('/')
      subject.driver.resize_window(200, 200)
      subject.find(:css, '#one').click
      expect(subject.find(:css, '#one')['data-click-x']).to eq '149'
      expect(subject.find(:css, '#one')['data-click-y']).to eq '99'
    end

    it 'does not raise an error when an anchor contains empty nodes' do
      subject.visit('/')
      expect { subject.click_link('Some link') }.not_to raise_error
    end

    it 'scrolls an element into view when clicked' do
      subject.visit('/')
      subject.driver.resize_window(200, 200)
      subject.find(:css, '#two').click
      expect(subject.find(:css, '#two')['data-click-x']).not_to be_nil
      expect(subject.find(:css, '#two')['data-click-y']).not_to be_nil
    end

    it 'raises an error if an element is obscured when clicked' do
      subject.visit('/')

      subject.execute_script(<<-JS)
        var two = document.getElementById('two');
        two.style.position = 'absolute';
        two.style.left = '0px';
        two.style.top = '0px';
      JS

      expect {
        subject.find(:css, '#one').click
      }.to raise_error(Capybara::Webkit::ClickFailed) { |exception|
        expect(exception.message).to match %r{Failed.*\[@id='one'\].*overlapping.*\[@id='two'\].*at position}
        screenshot_pattern = %r{A screenshot of the page at the time of the failure has been written to (.*)}
        expect(exception.message).to match screenshot_pattern
        file = exception.message.match(screenshot_pattern)[1]
        expect(File.exist?(file)).to be true
      }
    end

    it 'raises an error if a checkbox is obscured when checked' do
      subject.visit('/')

      subject.execute_script(<<-JS)
        var div = document.createElement('div');
        div.style.position = 'absolute';
        div.style.left = '0px';
        div.style.top = '0px';
        div.style.width = '100%';
        div.style.height = '100%';
        document.body.appendChild(div);
      JS

      expect {
        subject.check('bar')
      }.to raise_error(Capybara::Webkit::ClickFailed)
    end

    it 'raises an error if an element is not visible when clicked' do
      ignore_hidden_elements = Capybara.ignore_hidden_elements
      Capybara.ignore_hidden_elements = false
      begin
        subject.visit('/')
        subject.execute_script "document.getElementById('foo').style.display = 'none'"
        expect { subject.click_link "Click Me" }.to raise_error(
          Capybara::Webkit::ClickFailed,
          /\[@id='foo'\].*visible/
        )
      ensure
        Capybara.ignore_hidden_elements = ignore_hidden_elements
      end
    end

    it 'raises an error if an element is not in the viewport when clicked' do
      subject.visit('/')
      expect { subject.click_link "Click Me" }.to raise_error(Capybara::Webkit::ClickFailed)
    end

    context "with wait time of 1 second" do
      around do |example|
        Capybara.using_wait_time(1) do
          example.run
        end
      end

      it "waits for an element to appear in the viewport when clicked" do
        subject.visit('/')
        subject.execute_script <<-JS
          setTimeout(function() {
            var offscreen = document.getElementById('offscreen')
            offscreen.style.left = '10px';
          }, 400);
        JS

        expect { subject.click_link "Click Me" }.not_to raise_error
      end
    end
  end

  context 'styled upload app' do
    let(:session) do
      session_for_app do
        get '/render_form' do
          <<-HTML
            <html>
              <head>
                <style type="text/css">
                  #wrapper { position: relative; }
                  input[type=file] {
                    position: relative;
                    opacity: 0;
                    z-index: 2;
                    width: 50px;
                  }
                  #styled {
                    position: absolute;
                    top: 0;
                    left: 0;
                    z-index: 1;
                    width: 50px;
                  }
                </style>
              </head>
              <body>
                <form action="/submit" method="post" enctype="multipart/form-data">
                  <label for="file">File</label>
                  <div id="wrapper">
                    <input type="file" name="file" id="file" />
                    <div id="styled">Upload</div>
                  </div>
                  <input type="submit" value="Go" />
                </form>
              </body>
            </html>
          HTML
        end

        post '/submit' do
          contents = params[:file][:tempfile].read
          "You uploaded: #{contents}"
        end
      end
    end

    it 'attaches uploads' do
      file = Tempfile.new('example')
      file.write('Hello')
      file.flush

      session.visit('/render_form')
      session.attach_file 'File', file.path
      session.click_on 'Go'

      expect(session).to have_text('Hello')
    end
  end

  if Capybara.respond_to?(:threadsafe)
    context "threadsafe/per-session config mode" do
      before do
        Capybara::SpecHelper.reset_threadsafe(true, subject)
      end

      after do
        Capybara::SpecHelper.reset_threadsafe(false, subject)
      end

      it "can allow reload in one session but not in another" do
        session1, session2 = 2.times.collect do
          session_for_app do
            get '/' do
              <<-HTML
                <html>
                  <div id="parent">
                    <p id="removeMe">Hello</p>
                  </div>
                </html>
              HTML
            end
          end
        end

        session1.config.automatic_reload = false
        session2.config.automatic_reload = true

        node1, node2 = [session1, session2].map do |session|
          session.visit('/')

          node = session.find(:xpath, "//p[@id='removeMe']")
          session.execute_script("document.getElementById('parent').innerHTML = 'Magic'")
          node
        end

        expect(node1.text).to eq 'Hello'
        expect{ node2.text }.to raise_error(Capybara::Webkit::NodeNotAttachedError)
      end
    end
  end
end
