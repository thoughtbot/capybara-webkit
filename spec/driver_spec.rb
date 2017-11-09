# -*- encoding: UTF-8 -*-

require 'spec_helper'
require 'capybara/webkit/driver'
require 'base64'
require 'self_signed_ssl_cert'

describe Capybara::Webkit::Driver do
  include AppRunner

  def visit(path, driver=self.driver)
    driver.visit(url(path))
  end

  def url(path)
    "#{AppRunner.app_host}#{path}"
  end

  context "configuration" do
    let(:options) { AppRunner.configuration.to_hash }

    it "configures server automatically" do
      expect { Capybara::Webkit::Driver.new(AppRunner.app, options) }.
        to_not raise_error
    end
  end

  context "iframe app" do
    let(:driver) do
      driver_for_app do
        get "/" do
          if params[:iframe] == "true"
            redirect '/iframe'
          else
            <<-HTML
              <html>
                <head>
                  <style type="text/css">
                    #display_none { display: none }
                  </style>
                </head>
                <body>
                  <iframe id="f" src="/?iframe=true"></iframe>
                  <script type="text/javascript">
                    document.write("<p id='greeting'>hello</p>");
                  </script>
                </body>
              </html>
            HTML
          end
        end

        get '/iframe' do
          headers 'X-Redirected' => 'true'
          <<-HTML
            <html>
              <head>
                <title>Title</title>
                <style type="text/css">
                  #display_none { display: none }
                </style>
              </head>
              <body>
                <script type="text/javascript">
                  document.write("<p id='farewell'>goodbye</p><iframe id='g' src='/iframe2'></iframe>");
                </script>
              </body>
            </html>
          HTML
        end

        get '/iframe2' do
          <<-HTML
            <html>
              <head>
                <title>Frame 2</title>
              </head>
              <body>
                <div>In frame 2</div>
              </body>
            </html>
          HTML
        end
      end
    end

    before do
      visit("/")
    end

    it "finds frames by index" do
      driver.within_frame(0) do
        expect(driver.find_xpath("//*[contains(., 'goodbye')]")).not_to be_empty
      end
    end

    it "finds frames by id" do
      driver.within_frame("f") do
        expect(driver.find_xpath("//*[contains(., 'goodbye')]")).not_to be_empty
      end
    end

    it "finds frames by element" do
      frame = driver.find_xpath('//iframe').first
      element = double(Capybara::Node::Base, base: frame)
      driver.within_frame(element) do
        expect(driver.find_xpath("//*[contains(., 'goodbye')]")).not_to be_empty
      end
    end

    it "switches to frame by element" do
      frame = driver.find_xpath('//iframe').first
      element = double(Capybara::Node::Base, base: frame)
      driver.switch_to_frame(element)
      expect(driver.find_xpath("//*[contains(., 'goodbye')]")).not_to be_empty
      driver.switch_to_frame(:parent)
    end

    it "can switch back to the parent frame" do
      frame = driver.find_xpath('//iframe').first
      element = double(Capybara::Node::Base, base: frame)
      driver.switch_to_frame(element)
      driver.switch_to_frame(:parent)
      expect(driver.find_xpath("//*[contains(., 'greeting')]")).not_to be_empty
      expect(driver.find_xpath("//*[contains(., 'goodbye')]")).to be_empty
    end

    it "can switch to the top frame" do
      frame = driver.find_xpath('//iframe').first
      element = double(Capybara::Node::Base, base: frame)
      driver.switch_to_frame(element)
      frame2 = driver.find_xpath('//iframe[@id="g"]').first
      element2 = double(Capybara::Node::Base, base: frame2)
      driver.switch_to_frame(element2)
      expect(driver.find_xpath("//div[contains(., 'In frame 2')]")).not_to be_empty
      driver.switch_to_frame(:top)
      expect(driver.find_xpath("//*[contains(., 'greeting')]")).not_to be_empty
      expect(driver.find_xpath("//*[contains(., 'goodbye')]")).to be_empty
      expect(driver.find_xpath("//div[contains(., 'In frame 2')]")).to be_empty
    end

    it "raises error for missing frame by index" do
      expect { driver.within_frame(1) { } }.
        to raise_error(Capybara::Webkit::InvalidResponseError)
    end

    it "raise_error for missing frame by id" do
      expect { driver.within_frame("foo") { } }.
        to raise_error(Capybara::Webkit::InvalidResponseError)
    end

    it "returns an attribute's value" do
      driver.within_frame("f") do
        expect(driver.find_xpath("//p").first["id"]).to eq "farewell"
      end
    end

    it "returns an attribute's innerHTML" do
      expect(driver.find_xpath('//body').first.inner_html).to match %r{<iframe.*</iframe>.*<script.*</script>.*}m
    end

    it "receive an attribute's innerHTML" do
      driver.find_xpath('//body').first.inner_html = 'foobar'
      expect(driver.find_xpath("//body[contains(., 'foobar')]")).not_to be_empty
    end

    it "returns a node's text" do
      driver.within_frame("f") do
        expect(driver.find_xpath("//p").first.visible_text).to eq "goodbye"
      end
    end

    it "returns the current URL" do
      driver.within_frame("f") do
        expect(driver.current_url).to eq driver_url(driver, "/iframe")
      end
    end

    it "evaluates Javascript" do
      driver.within_frame("f") do
        result = driver.evaluate_script(%<document.getElementById('farewell').innerText>)
        expect(result).to eq "goodbye"
      end
    end

    it "executes Javascript" do
      driver.within_frame("f") do
        driver.execute_script(%<document.getElementById('farewell').innerHTML = 'yo'>)
        expect(driver.find_xpath("//p[contains(., 'yo')]")).not_to be_empty
      end
    end

    it "returns focus to parent" do
      original_url = driver.current_url

      driver.within_frame("f") {}

      expect(driver.current_url).to eq original_url
    end

    it "returns the headers for the page" do
      driver.within_frame("f") do
        expect(driver.response_headers['X-Redirected']).to eq "true"
      end
    end

    it "returns the status code for the page" do
      driver.within_frame("f") do
        expect(driver.status_code).to eq 200
      end
    end

    it "returns the document title" do
      driver.within_frame("f") do
        expect(driver.title).to eq "Title"
      end
    end
  end

  context "error iframe app" do
    let(:driver) do
      driver_for_app do
        get "/inner-not-found" do
          invalid_response
        end

        get "/" do
          <<-HTML
            <html>
              <body>
                <iframe src="/inner-not-found"></iframe>
              </body>
            </html>
          HTML
        end
      end
    end

    it "raises error whose message references the actual missing url" do
      expect { visit("/") }.to raise_error(Capybara::Webkit::InvalidResponseError, /inner-not-found/)
    end
  end

  context "redirect app" do
    let(:driver) do
      driver_for_app do
        enable :sessions

        get '/target' do
          headers 'X-Redirected' => (session.delete(:redirected) || false).to_s
          "<p>#{env['CONTENT_TYPE']}</p>"
        end

        get '/form' do
          <<-HTML
            <html>
              <body>
                <form action="/redirect" method="POST" enctype="multipart/form-data">
                  <input name="submit" type="submit" />
                </form>
              </body>
            </html>
          HTML
        end

        post '/redirect' do
          redirect '/target'
        end

        get '/redirect-me' do
          if session[:redirected]
            redirect '/target'
          else
            session[:redirected] = true
            redirect '/redirect-me'
          end
        end
      end
    end

    it "should redirect without content type" do
      visit("/form")
      driver.find_xpath("//input").first.click
      expect(driver.find_xpath("//p").first.visible_text).to eq ""
    end

    it "returns the current URL when changed by pushState after a redirect" do
      visit("/redirect-me")
      expect(driver.current_url).to eq driver_url(driver, "/target")
      driver.execute_script("window.history.pushState({}, '', '/pushed-after-redirect')")
      expect(driver.current_url).to eq driver_url(driver, "/pushed-after-redirect")
    end

    it "returns the current URL when changed by replaceState after a redirect" do
      visit("/redirect-me")
      expect(driver.current_url).to eq driver_url(driver, "/target")
      driver.execute_script("window.history.replaceState({}, '', '/replaced-after-redirect')")
      expect(driver.current_url).to eq driver_url(driver, "/replaced-after-redirect")
    end

    it "should make headers available through response_headers" do
      visit('/redirect-me')
      expect(driver.response_headers['X-Redirected']).to eq "true"
      visit('/target')
      expect(driver.response_headers['X-Redirected']).to eq "false"
    end

    it "should make the status code available through status_code" do
      visit('/redirect-me')
      expect(driver.status_code).to eq 200
      visit('/target')
      expect(driver.status_code).to eq 200
    end
  end

  context "css app" do
    let(:driver) do
      driver_for_app do
        get "/" do
          headers "Content-Type" => "text/css"
          "css"
        end
      end
    end

    before { visit("/") }

    it "renders unsupported content types gracefully" do
      expect(driver.html).to match /css/
    end

    it "sets the response headers with respect to the unsupported request" do
      expect(driver.response_headers["Content-Type"]).to eq "text/css"
    end

    it "does not wrap the content in HTML tags" do
      expect(driver.html).not_to match /<html>/
    end
  end

  context "html app" do
    let(:driver) do
      driver_for_html(<<-HTML)
        <html>
          <head>
            <title>Hello HTML</title>
          </head>
          <body>
            <h1>This Is HTML!</h1>
          </body>
        </html>
      HTML
    end

    before { visit("/") }

    it "does not strip HTML tags" do
      expect(driver.html).to match /<html>/
    end
  end

  context "binary content app" do
    let(:driver) do
      driver_for_app do
        get '/' do
          headers 'Content-Type' => 'application/octet-stream'
          "Hello\xFF\xFF\xFF\xFFWorld"
        end
      end
    end

    before { visit("/") }

    it "should return the binary content" do
      src = driver.html.force_encoding('binary')
      expect(src).to eq "Hello\xFF\xFF\xFF\xFFWorld".force_encoding('binary')
    end
  end

  context "hello app" do
    let(:driver) do
      driver_for_html(<<-HTML)
        <html>
          <head>
            <title>Title</title>
            <style type="text/css">
              #display_none { display: none }
              #visibility_hidden { visibility: hidden }
            </style>
          </head>
          <body>
            <div class='normalize'>Spaces&nbsp;not&nbsp;normalized&nbsp;</div>
            <div id="display_none">
              <div id="invisible">Can't see me</div>
            </div>
            <div id="visibility_hidden">
              <div id="invisible_with_visibility">Can't see me too</div>
            </div>
            <div id="hidden-text">
              Some of this text is <em style="display:none">hidden!</em>
            </div>
            <div id="hidden-ancestor" style="display: none">
              <div>Hello</div>
            </div>
            <input type="text" disabled="disabled"/>
            <input id="checktest" type="checkbox" checked="checked"/>
            <script type="text/javascript">
              document.write("<p id='greeting'>he" + "llo</p>");
            </script>
          </body>
        </html>
      HTML
    end

    before { visit("/") }

    it "doesn't return text if the ancestor is hidden" do
      visit("/")

      expect(driver.find_css("#hidden-ancestor div").first.text).to eq ''
    end

    it "handles anchor tags" do
      visit("#test")
      expect(driver.find_xpath("//*[contains(., 'hello')]")).not_to be_empty
      visit("#test")
      expect(driver.find_xpath("//*[contains(., 'hello')]")).not_to be_empty
    end

    it "finds content after loading a URL" do
      expect(driver.find_xpath("//*[contains(., 'hello')]")).not_to be_empty
    end

    it "has an empty page after reseting" do
      driver.reset!
      expect(driver.find_xpath("//*[contains(., 'hello')]")).to be_empty
    end

    it "has a blank location after reseting" do
      driver.reset!
      expect(driver.current_url).to eq "about:blank"
    end

    it "raises an error for an invalid xpath query" do
      expect { driver.find_xpath("totally invalid salad") }.
        to raise_error(Capybara::Webkit::InvalidResponseError, /xpath/i)
    end

    it "raises an error for an invalid xpath query within an element" do
      expect { driver.find_xpath("//body").first.find_xpath("totally invalid salad") }.
        to raise_error(Capybara::Webkit::InvalidResponseError, /xpath/i)
    end

    it "returns an attribute's value" do
      expect(driver.find_xpath("//p").first["id"]).to eq "greeting"
    end

    it "parses xpath with quotes" do
      expect(driver.find_xpath('//*[contains(., "hello")]')).not_to be_empty
    end

    it "returns a node's visible text" do
      expect(driver.find_xpath("//*[@id='hidden-text']").first.visible_text).to eq "Some of this text is"
    end

    it "normalizes a node's text" do
      expect(driver.find_xpath("//div[contains(@class, 'normalize')]").first.visible_text).to eq "Spaces not normalized"
    end

    it "returns all of a node's text" do
      expect(driver.find_xpath("//*[@id='hidden-text']").first.all_text).to eq "Some of this text is hidden!"
    end

    it "returns the current URL" do
      visit "/hello/world?success=true"
      expect(driver.current_url).to eq driver_url(driver, "/hello/world?success=true")
    end

    it "returns the current URL when changed by pushState" do
      driver.execute_script("window.history.pushState({}, '', '/pushed')")
      expect(driver.current_url).to eq driver_url(driver, "/pushed")
    end

    it "returns the current URL when changed by replaceState" do
      driver.execute_script("window.history.replaceState({}, '', '/replaced')")
      expect(driver.current_url).to eq driver_url(driver, "/replaced")
    end

    it "does not double-encode URLs" do
      visit("/hello/world?success=%25true")
      expect(driver.current_url).to match /success=\%25true/
    end

    it "returns the current URL with encoded characters" do
      visit("/hello/world?success[value]=true")
      current_url = Rack::Utils.unescape(driver.current_url)
      expect(current_url).to include('success[value]=true')
    end

    it "visits a page with an anchor" do
      visit("/hello#display_none")
      expect(driver.current_url).to match /hello#display_none/
    end

    it "evaluates Javascript and returns a string" do
      result = driver.evaluate_script(%<document.getElementById('greeting').innerText>)
      expect(result).to eq "hello"
    end

    it "evaluates Javascript and returns an array" do
      result = driver.evaluate_script(%<["hello", "world"]>)
      expect(result).to eq %w(hello world)
    end

    it "evaluates Javascript and returns an int" do
      result = driver.evaluate_script(%<123>)
      expect(result).to eq 123
    end

    it "evaluates Javascript and returns a float" do
      result = driver.evaluate_script(%<1.5>)
      expect(result).to eq 1.5
    end

    it "evaluates Javascript and returns an element" do
      result = driver.evaluate_script(%<document.getElementById('greeting')>)
      expect(result).to eq driver.find_css("#greeting").first
    end

    it "evaluates Javascript and returns a structure containing elements" do
      result = driver.evaluate_script(%<({ 'a': document.getElementById('greeting'), 'b': { 'c': document.querySelectorAll('#greeting, #checktest') } })>)
      expect(result).to eq(
        "a" => driver.find_css("#greeting").first,
        "b" => {
          "c" => driver.find_css("#greeting, #checktest")
        },
      )
    end

    it "evaluates Javascript and returns null" do
      result = driver.evaluate_script(%<(function () {})()>)
      expect(result).to eq nil
    end

    it "evaluates Infinity and returns null" do
      result = driver.evaluate_script(%<Infinity>)
      expect(result).to eq nil
    end

    it "evaluates Javascript and returns a date" do
      result = driver.evaluate_script(%<new Date("2016-04-01T00:00:00Z")>)
      expect(result).to eq "2016-04-01T00:00:00Z"
    end

    it "evaluates Javascript and returns an object" do
      result = driver.evaluate_script(%<({ 'one' : 1 })>)
      expect(result).to eq "one" => 1
    end

    it "evaluate Javascript and returns an object when the original was readonly" do
      result = driver.evaluate_script(%<window.getComputedStyle(document.getElementById('greeting'))>)
      expect(result).to be_a Hash
      expect(result["zIndex"]).to eq "auto"
    end

    it "evaluates Javascript and returns true" do
      result = driver.evaluate_script(%<true>)
      expect(result).to be true
    end

    it "evaluates Javascript and returns false" do
      result = driver.evaluate_script(%<false>)
      expect(result).to be false
    end

    it "evaluates Javascript and returns an escaped string" do
      result = driver.evaluate_script(%<'"'>)
      expect(result).to eq "\""
    end

    it "evaluates Javascript with multiple lines" do
      result = driver.evaluate_script("[1,\n2]")
      expect(result).to eq [1, 2]
    end

    it "evaluates asynchronous JS which isn't" do
      result = driver.evaluate_async_script("arguments[0](4)")
      expect(result).to eq 4
    end

    it "evaluates asynchronous JS" do
      result = driver.evaluate_async_script("setTimeout(function(callback){ callback('jaguar') }, 100, arguments[0])")
      expect(result).to eq "jaguar"
    end

    it "evaluates asynchronous JS and returns an object" do
      result = driver.evaluate_async_script(%<setTimeout(function(callback){ callback({ 'one' : 1 }) }, 100, arguments[0])>)
      expect(result).to eq "one" => 1
    end

    it "evaluates asynchronous JS and returns an object when the original was readonly" do
      result = driver.evaluate_async_script(%<setTimeout(function(callback){ callback(window.getComputedStyle(document.getElementById('greeting'))) }, 100, arguments[0])>)
      expect(result).to be_a Hash
      expect(result["zIndex"]).to eq "auto"
    end

    it "executes Javascript" do
      driver.execute_script(%<document.getElementById('greeting').innerHTML = 'yo'>)
      expect(driver.find_xpath("//p[contains(., 'yo')]")).not_to be_empty
    end

    it "raises an error for failing Javascript" do
      expect { driver.execute_script(%<invalid salad>) }.
        to raise_error(Capybara::Webkit::InvalidResponseError)
    end

    it "passes arguments to executed Javascript" do
      driver.execute_script(%<document.getElementById('greeting').innerHTML = arguments[0]>, "My argument")
      expect(driver.find_xpath("//p[contains(., 'My argument')]")).not_to be_empty
    end

    it "passes multiple arguments to executed Javascript" do
      driver.execute_script(
        %<document.getElementById('greeting').innerHTML = arguments[0] + arguments[1] + arguments[2].color>,
        "random", 4, {color: 'red'})
      expect(driver.find_xpath("//p[contains(., 'random4red')]")).not_to be_empty
    end

    it "passes page elements to executed Javascript" do
      greeting = driver.find_xpath("//p[@id='greeting']").first
      driver.execute_script(%<arguments[0].innerHTML = arguments[1]>, greeting, "new content")
      expect(driver.find_xpath("//p[@id='greeting'][contains(., 'new content')]")).not_to be_empty
    end

    it "passes elements as arguments to asynchronous script" do
      greeting = driver.find_xpath("//p[@id='greeting']").first
      result = driver.evaluate_async_script(%<arguments[2]([arguments[1], arguments[0]])>, greeting, "a string")
      expect(result).to eq ["a string", greeting]
    end

    it "passes arguments to evaaluated Javascript" do
      expect(driver.evaluate_script(%<arguments[0]>, 3)).to eq 3
    end

    it "passes multiple arguments to evaluated Javascript" do
      expect(driver.evaluate_script(%<arguments[0] + arguments[1] + arguments[2].num>, 3, 4, {num: 5})).to eq 12
    end

    it "passes page elements to evaluated Javascript" do
      greeting = driver.find_xpath("//p[@id='greeting']").first
      expect(driver.evaluate_script(%<arguments[1].innerHTML = arguments[0]; arguments[2]>, "newer content", greeting, 7)).to eq 7
      expect(driver.find_xpath("//p[@id='greeting'][contains(., 'newer content')]")).not_to be_empty
    end

    it "doesn't raise an error for Javascript that doesn't return anything" do
      expect { driver.execute_script(%<(function () { "returns nothing" })()>) }.not_to raise_error
    end

    it "returns a node's tag name" do
      expect(driver.find_xpath("//p").first.tag_name).to eq "p"
    end

    it "reads disabled property" do
      expect(driver.find_xpath("//input").first).to be_disabled
    end

    it "reads checked property" do
      expect(driver.find_xpath("//input[@id='checktest']").first).to be_checked
    end

    it "finds visible elements" do
      expect(driver.find_xpath("//p").first).to be_visible
      expect(driver.find_xpath("//*[@id='invisible']").first).not_to be_visible
      expect(driver.find_xpath("//*[@id='invisible_with_visibility']").first).not_to be_visible
    end

    it "returns the document title" do
      expect(driver.title).to eq "Title"
    end

    it "finds elements by CSS" do
      expect(driver.find_css("p").first.visible_text).to eq "hello"
    end
  end

  context "svg app" do
    let(:driver) do
      driver_for_html(<<-HTML)
        <html>
          <body>
            <svg xmlns="http://www.w3.org/2000/svg" version="1.1" height="100">
              <text x="10" y="25" fill="navy" font-size="15" id="navy_text">In the navy!</text>
            </svg>
          </body>
        </html>
      HTML
    end

    before { visit("/") }

    it "should handle text for svg elements" do
      expect(driver.find_xpath("//*[@id='navy_text']").first.visible_text).to eq "In the navy!"
    end
  end

  context "hidden text app" do
    let(:driver) do
      driver_for_html(<<-HTML)
        <html>
          <body>
            <h1 style="display: none">Hello</h1>
          </body>
        </html>
      HTML
    end

    before { visit("/") }

    it "has no visible text" do
      expect(driver.find_xpath("/html").first.text).to be_empty
    end
  end

  context "console messages app" do
    let(:driver) do
      driver_for_html(<<-HTML)
        <html>
          <head>
          <meta http-equiv="content-type" content="text/html; charset=UTF-8">
          </head>
          <body>
            <script type="text/javascript">
              console.log("hello");
              console.log("hello again");
              console.log("hello\\nnewline");
              console.log("𝄞");
              oops
            </script>
          </body>
        </html>
      HTML
    end

    before { visit("/") }

    it "collects messages logged to the console" do
      url = driver_url(driver, "/")
      message = driver.console_messages.first
      expect(message).to include :source => url, :message => "hello"
      expect([6, 7]).to include message[:line_number]
      expect(driver.console_messages.length).to eq 5
    end

    it "logs errors to the console" do
      expect(driver.error_messages.length).to eq 1
    end

    it "supports multi-line console messages" do
      message = driver.console_messages[2]
      expect(message[:message]).to eq "hello\nnewline"
    end

    it "empties the array when reset" do
      driver.reset!
      expect(driver.console_messages).to be_empty
    end

    it "supports console messages from an unknown source" do
      driver.execute_script("console.log('hello')")
      expect(driver.console_messages.last[:message]).to eq 'hello'
      expect(driver.console_messages.last[:source]).to be_nil
      expect(driver.console_messages.last[:line_number]).to be_nil
    end

    it "escapes unicode console messages" do
      expect(driver.console_messages[3][:message]).to eq '𝄞'
    end
  end

  context "javascript dialog interaction" do
    before do
      stub_const('Capybara::ModalNotFound', Class.new(StandardError))
    end

    context "on an alert app" do
      let(:driver) do
        driver_for_app do
          get '/' do
            <<-HTML
              <html>
                <head>
                </head>
                <body>
                  <script type="text/javascript">
                    alert("Alert Text\\nGoes Here");
                  </script>
                </body>
              </html>
            HTML
          end

          get '/async' do
            <<-HTML
              <html>
                <head>
                </head>
                <body>
                  <script type="text/javascript">
                    function testAlert() {
                      setTimeout(function() { alert("Alert Text\\nGoes Here"); },
                        #{params[:sleep] || 100});
                    }
                  </script>
                  <input type="button" onclick="testAlert()" name="test"/>
                </body>
              </html>
            HTML
          end

          get '/ajax' do
            <<-HTML
              <html>
                <head>
                </head>
                <body>
                  <script type="text/javascript">
                    function testAlert() {
                      var xhr = new XMLHttpRequest();
                      xhr.open('GET', '/slow', true);
                      xhr.setRequestHeader('Content-Type', 'text/plain');
                      xhr.onreadystatechange = function () {
                        if (xhr.readyState == 4) {
                          alert('From ajax');
                        }
                      };
                      xhr.send();
                    }
                  </script>
                  <input type="button" onclick="testAlert()" name="test"/>
                </body>
              </html>
            HTML
          end

          get '/double' do
            <<-HTML
              <html>
                <head>
                </head>
                <body>
                  <script type="text/javascript">
                    alert('First alert');
                  </script>
                  <input type="button" onclick="alert('Second alert')" name="test"/>
                </body>
              </html>
            HTML
          end

          get '/slow' do
            sleep 0.5
            ""
          end
        end
      end

      it 'accepts any alert modal if no match is provided' do
        alert_message = driver.accept_modal(:alert) do
          visit("/")
        end
        expect(alert_message).to eq "Alert Text\nGoes Here"
      end

      it 'accepts an alert modal if it matches' do
        alert_message = driver.accept_modal(:alert, text: "Alert Text\nGoes Here") do
          visit("/")
        end
        expect(alert_message).to eq "Alert Text\nGoes Here"
      end

      it 'raises an error when accepting an alert modal that does not match' do
        expect {
          driver.accept_modal(:alert, text: 'No?') do
            visit('/')
          end
        }.to raise_error Capybara::ModalNotFound, "Unable to find modal dialog with No?"
      end

      it 'finds two alert windows in a row' do
        driver.accept_modal(:alert, text: 'First alert') do
          visit('/double')
        end

        expect {
          driver.accept_modal(:alert, text: 'Boom') do
            driver.find_xpath("//input").first.click
          end
        }.to raise_error Capybara::ModalNotFound, "Unable to find modal dialog with Boom"
      end

      it 'waits to accept an async alert modal' do
        visit("/async")
        alert_message = driver.accept_modal(:alert) do
          driver.find_xpath("//input").first.click
        end
        expect(alert_message).to eq "Alert Text\nGoes Here"
      end

      it 'times out waiting for an async alert modal' do
        visit("/async?sleep=1000")
        expect {
          driver.accept_modal(:alert, wait: 0.1) do
            driver.find_xpath("//input").first.click
          end
        }.to raise_error Capybara::ModalNotFound, "Timed out waiting for modal dialog"
      end

      it 'raises an error when an unexpected modal is displayed' do
        expect {
          driver.accept_modal(:confirm) do
            visit("/")
          end
        }.to raise_error Capybara::ModalNotFound, "Unable to find modal dialog"
      end

      it "should let me read my alert messages" do
        visit("/")
        expect(driver.alert_messages.first).to eq "Alert Text\nGoes Here"
      end

      it "empties the array when reset" do
        visit("/")
        driver.reset!
        expect(driver.alert_messages).to be_empty
      end

      it "clears alerts from ajax requests in between sessions" do
        visit("/ajax")
        driver.find("//input").first.click
        driver.reset!
        sleep 0.5
        expect(driver.alert_messages).to eq([])
        expect { visit("/") }.not_to raise_error
      end
    end

    context "on a confirm app" do
      let(:driver) do
        driver_for_html(<<-HTML)
          <html>
            <head>
            </head>
            <body>
              <script type="text/javascript">
                function test_dialog() {
                  if(confirm("Yes?"))
                    console.log("hello");
                  else
                    console.log("goodbye");
                }
                function test_complex_dialog() {
                  if(confirm("Yes?"))
                    if(confirm("Really?"))
                      console.log("hello");
                  else
                    console.log("goodbye");
                }
                function test_async_dialog() {
                  setTimeout(function() {
                    if(confirm("Yes?"))
                      console.log("hello");
                    else
                      console.log("goodbye");
                  }, 100);
                }
              </script>
              <input type="button" onclick="test_dialog()" name="test"/>
              <input type="button" onclick="test_complex_dialog()" name="test_complex"/>
              <input type="button" onclick="test_async_dialog()" name="test_async"/>
            </body>
          </html>
        HTML
      end

      before { visit("/") }

      it 'accepts any confirm modal if no match is provided' do
        driver.accept_modal(:confirm) do
          driver.find_xpath("//input").first.click
        end
        expect(driver.console_messages.first[:message]).to eq "hello"
      end

      it 'dismisses a confirm modal that does not match' do
        begin
          driver.accept_modal(:confirm, text: 'No?') do
            driver.find_xpath("//input").first.click
            expect(driver.console_messages.first[:message]).to eq "goodbye"
          end
        rescue Capybara::ModalNotFound
        end
      end

      it 'raises an error when accepting a confirm modal that does not match' do
        expect {
          driver.accept_modal(:confirm, text: 'No?') do
            driver.find_xpath("//input").first.click
          end
        }.to raise_error Capybara::ModalNotFound, "Unable to find modal dialog with No?"
      end

      it 'dismisses any confirm modal if no match is provided' do
        driver.dismiss_modal(:confirm) do
          driver.find_xpath("//input").first.click
        end
        expect(driver.console_messages.first[:message]).to eq "goodbye"
      end

      it 'raises an error when dismissing a confirm modal that does not match' do
        expect {
          driver.dismiss_modal(:confirm, text: 'No?') do
            driver.find_xpath("//input").first.click
          end
        }.to raise_error Capybara::ModalNotFound, "Unable to find modal dialog with No?"
      end

      it 'waits to accept an async confirm modal' do
        visit("/async")
        confirm_message = driver.accept_modal(:confirm) do
          driver.find_css("input[name=test_async]").first.click
        end
        expect(confirm_message).to eq "Yes?"
      end

      it 'allows the nesting of dismiss and accept' do
        driver.dismiss_modal(:confirm) do
          driver.accept_modal(:confirm) do
            driver.find_css("input[name=test_complex]").first.click
          end
        end
        expect(driver.console_messages.first[:message]).to eq "goodbye"
      end

      it 'raises an error when an unexpected modal is displayed' do
        expect {
          driver.accept_modal(:prompt) do
            driver.find_xpath("//input").first.click
          end
        }.to raise_error Capybara::ModalNotFound, "Unable to find modal dialog"
      end

      it 'dismisses a confirm modal when prompt is expected' do
        begin
          driver.accept_modal(:prompt) do
            driver.find_xpath("//input").first.click
            expect(driver.console_messages.first[:message]).to eq "goodbye"
          end
        rescue Capybara::ModalNotFound
        end
      end

      it "should default to accept the confirm" do
        driver.find_xpath("//input").first.click
        expect(driver.console_messages.first[:message]).to eq "hello"
      end

      it "can dismiss the confirm" do
        driver.dismiss_js_confirms!
        driver.find_xpath("//input").first.click
        expect(driver.console_messages.first[:message]).to eq "goodbye"
      end

      it "can accept the confirm explicitly" do
        driver.dismiss_js_confirms!
        driver.accept_js_confirms!
        driver.find_xpath("//input").first.click
        expect(driver.console_messages.first[:message]).to eq "hello"
      end

      it "should collect the javascript confirm dialog contents" do
        driver.find_xpath("//input").first.click
        expect(driver.confirm_messages.first).to eq "Yes?"
      end

      it "empties the array when reset" do
        driver.find_xpath("//input").first.click
        driver.reset!
        expect(driver.confirm_messages).to be_empty
      end

      it "resets to the default of accepting confirms" do
        driver.dismiss_js_confirms!
        driver.reset!
        visit("/")
        driver.find_xpath("//input").first.click
        expect(driver.console_messages.first[:message]).to eq "hello"
      end

      it "supports multi-line confirmation messages" do
        driver.execute_script("confirm('Hello\\nnewline')")
        expect(driver.confirm_messages.first).to eq "Hello\nnewline"
      end

    end

    context "on a prompt app" do
      let(:driver) do
        driver_for_html(<<-HTML)
          <html>
            <head>
            </head>
            <body>
              <script type="text/javascript">
                function test_dialog() {
                  var response = prompt("Your name?", "John Smith");
                  if(response != null)
                    console.log("hello " + response);
                  else
                    console.log("goodbye");
                }
                function test_complex_dialog() {
                  var response = prompt("Your name?", "John Smith");
                  if(response != null)
                    if(prompt("Your age?"))
                      console.log("hello " + response);
                  else
                    console.log("goodbye");
                }
                function test_async_dialog() {
                  setTimeout(function() {
                    var response = prompt("Your name?", "John Smith");
                  }, 100);
                }
              </script>
              <input type="button" onclick="test_dialog()" name="test"/>
              <input type="button" onclick="test_complex_dialog()" name="test_complex"/>
              <input type="button" onclick="test_async_dialog()" name="test_async"/>
            </body>
          </html>
        HTML
      end

      before { visit("/") }

      it 'accepts any prompt modal if no match is provided' do
        driver.accept_modal(:prompt) do
          driver.find_xpath("//input").first.click
        end
        expect(driver.console_messages.first[:message]).to eq "hello John Smith"
      end

      it 'accepts any prompt modal with the provided response' do
        driver.accept_modal(:prompt, with: 'Capy') do
          driver.find_xpath("//input").first.click
        end
        expect(driver.console_messages.first[:message]).to eq "hello Capy"
      end

      it 'raises an error when accepting a prompt modal that does not match' do
        expect {
          driver.accept_modal(:prompt, text: 'Your age?') do
            driver.find_xpath("//input").first.click
          end
        }.to raise_error Capybara::ModalNotFound, "Unable to find modal dialog with Your age?"
      end

      it 'dismisses any prompt modal if no match is provided' do
        driver.dismiss_modal(:prompt) do
          driver.find_xpath("//input").first.click
        end
        expect(driver.console_messages.first[:message]).to eq "goodbye"
      end

      it 'dismisses a prompt modal that does not match' do
        begin
          driver.accept_modal(:prompt, text: 'Your age?') do
            driver.find_xpath("//input").first.click
            expect(driver.console_messages.first[:message]).to eq "goodbye"
          end
        rescue Capybara::ModalNotFound
        end
      end

      it 'raises an error when dismissing a prompt modal that does not match' do
        expect {
          driver.dismiss_modal(:prompt, text: 'Your age?') do
            driver.find_xpath("//input").first.click
          end
        }.to raise_error Capybara::ModalNotFound, "Unable to find modal dialog with Your age?"
      end

      it 'waits to accept an async prompt modal' do
        visit("/async")
        prompt_message = driver.accept_modal(:prompt) do
          driver.find_css("input[name=test_async]").first.click
        end
        expect(prompt_message).to eq "Your name?"
      end

      it 'allows the nesting of dismiss and accept' do
        driver.dismiss_modal(:prompt) do
          driver.accept_modal(:prompt) do
            driver.find_css("input[name=test_complex]").first.click
          end
        end
        expect(driver.console_messages.first[:message]).to eq "goodbye"
      end

      it 'raises an error when an unexpected modal is displayed' do
        expect {
          driver.accept_modal(:confirm) do
            driver.find_xpath("//input").first.click
          end
        }.to raise_error Capybara::ModalNotFound, "Unable to find modal dialog"
      end

      it 'dismisses a prompt modal when confirm is expected' do
        begin
          driver.accept_modal(:confirm) do
            driver.find_xpath("//input").first.click
            expect(driver.console_messages.first[:message]).to eq "goodbye"
          end
        rescue Capybara::ModalNotFound
        end
      end

      it "should default to dismiss the prompt" do
        driver.find_xpath("//input").first.click
        expect(driver.console_messages.first[:message]).to eq "goodbye"
      end

      it "can accept the prompt without providing text" do
        driver.accept_js_prompts!
        driver.find_xpath("//input").first.click
        expect(driver.console_messages.first[:message]).to eq "hello John Smith"
      end

      it "can accept the prompt with input" do
        driver.js_prompt_input = "Capy"
        driver.accept_js_prompts!
        driver.find_xpath("//input").first.click
        expect(driver.console_messages.first[:message]).to eq "hello Capy"
      end

      it "can return to dismiss the prompt after accepting prompts" do
        driver.accept_js_prompts!
        driver.dismiss_js_prompts!
        driver.find_xpath("//input").first.click
        expect(driver.console_messages.first[:message]).to eq "goodbye"
      end

      it "should let me remove the prompt input text" do
        driver.js_prompt_input = "Capy"
        driver.accept_js_prompts!
        driver.find_xpath("//input").first.click
        expect(driver.console_messages.first[:message]).to eq "hello Capy"
        driver.js_prompt_input = nil
        driver.find_xpath("//input").first.click
        expect(driver.console_messages.last[:message]).to eq "hello John Smith"
      end

      it "should collect the javascript prompt dialog contents" do
        driver.find_xpath("//input").first.click
        expect(driver.prompt_messages.first).to eq "Your name?"
      end

      it "empties the array when reset" do
        driver.find_xpath("//input").first.click
        driver.reset!
        expect(driver.prompt_messages).to be_empty
      end

      it "returns the prompt action to dismiss on reset" do
        driver.accept_js_prompts!
        driver.reset!
        visit("/")
        driver.find_xpath("//input").first.click
        expect(driver.console_messages.first[:message]).to eq "goodbye"
      end

      it "supports multi-line prompt messages" do
        driver.execute_script("prompt('Hello\\nnewline')")
        expect(driver.prompt_messages.first).to eq "Hello\nnewline"
      end

    end
  end

  context "form app" do
    let(:driver) do
      driver_for_html(<<-HTML)
        <html><body>
          <form action="/" method="GET">
            <input type="text" name="foo" value="bar"/>
            <input type="text" name="maxlength_foo" value="bar" maxlength="10"/>
            <input type="text" id="disabled_input" disabled="disabled"/>
            <input type="text" id="readonly_input" readonly="readonly" value="readonly"/>
            <input type="checkbox" name="checkedbox" value="1" checked="checked"/>
            <input type="checkbox" name="uncheckedbox" value="2"/>
            <select name="animal">
              <option id="select-option-monkey">Monkey</option>
              <option id="select-option-capybara" selected="selected">Capybara</option>
            </select>
            <select name="disabled" disabled="disabled">
              <option id="select-option-disabled">Disabled</option>
            </select>
            <select name="toppings" multiple="multiple">
              <optgroup label="Mediocre Toppings">
                <option selected="selected" id="topping-apple">Apple</option>
                <option selected="selected" id="topping-banana">Banana</option>
              </optgroup>
              <optgroup label="Best Toppings">
                <option selected="selected" id="topping-cherry">Cherry</option>
              </optgroup>
            </select>
            <select name="guitars" multiple>
              <option selected="selected" id="fender">Fender</option>
              <option selected="selected" id="gibson">Gibson</option>
            </select>
            <textarea id="only-textarea">what a wonderful area for text</textarea>
            <input type="radio" id="only-radio" value="1"/>
            <button type="reset">Reset Form</button>
          </form>
          <div id="key_events"></div>
          <script>
            var form = document.getElementsByTagName('form')[0];
            var output = document.getElementById('key_events');
            form.addEventListener('keydown', function(e){
              output.innerHTML = output.innerHTML + " d:" + (e.key || e.which);
            });
            form.addEventListener('keyup', function(e){
              output.innerHTML = output.innerHTML + " u:" + (e.key || e.which);
            });
          </script>
        </body></html>
      HTML
    end

    before { visit("/") }

    it "returns a textarea's value" do
      expect(driver.find_xpath("//textarea").first.value).to eq "what a wonderful area for text"
    end

    it "returns a text input's value" do
      expect(driver.find_xpath("//input").first.value).to eq "bar"
    end

    it "returns a select's value" do
      expect(driver.find_xpath("//select").first.value).to eq "Capybara"
    end

    it "sets an input's value" do
      input = driver.find_xpath("//input").first
      input.set("newvalue")
      expect(input.value).to eq "newvalue"
    end

    it "sets an input's value greater than the max length" do
      input = driver.find_xpath("//input[@name='maxlength_foo']").first
      input.set("allegories (poems)")
      expect(input.value).to eq "allegories"
    end

    it "sets an input's value equal to the max length" do
      input = driver.find_xpath("//input[@name='maxlength_foo']").first
      input.set("allegories")
      expect(input.value).to eq "allegories"
    end

    it "sets an input's value less than the max length" do
      input = driver.find_xpath("//input[@name='maxlength_foo']").first
      input.set("poems")
      expect(input.value).to eq "poems"
    end

    it "sets an input's nil value" do
      input = driver.find_xpath("//input").first
      input.set(nil)
      expect(input.value).to eq ""
    end

    it "sets a select's value" do
      select = driver.find_xpath("//select").first
      select.set("Monkey")
      expect(select.value).to eq "Monkey"
    end

    it "sets a textarea's value" do
      textarea = driver.find_xpath("//textarea").first
      textarea.set("newvalue")
      expect(textarea.value).to eq "newvalue"
    end

    context "#send_keys" do
      it "should support :backspace" do
        input = driver.find_xpath("//input").first
        input.set("dog")
        expect(input.value).to eq "dog"
        input.send_keys(*[:backspace])
        expect(input.value).to eq "do"
      end

      it "should support :modifiers" do
        input = driver.find_xpath("//input").first
        input.send_keys("abc", [:shift, :left], "def")
        expect(input.value).to eq "abdef"
        input.send_keys([:control, "a"], [:shift, "upper"])
        expect(input.value).to eq "UPPER"
      end

      it "releases modifiers correctly" do
        input = driver.find_xpath("//input").first
        input.send_keys("a", [:shift, :left], "a")
        event_text = driver.find_css("#key_events").first.text
        expect(event_text).to eq "d:65 u:65 d:16 d:37 u:37 u:16 d:65 u:65"
      end
    end

    let(:monkey_option)   { driver.find_xpath("//option[@id='select-option-monkey']").first }
    let(:capybara_option) { driver.find_xpath("//option[@id='select-option-capybara']").first }
    let(:animal_select)   { driver.find_xpath("//select[@name='animal']").first }
    let(:apple_option)    { driver.find_xpath("//option[@id='topping-apple']").first }
    let(:banana_option)   { driver.find_xpath("//option[@id='topping-banana']").first }
    let(:cherry_option)   { driver.find_xpath("//option[@id='topping-cherry']").first }
    let(:toppings_select) { driver.find_xpath("//select[@name='toppings']").first }
    let(:guitars_select)  { driver.find_xpath("//select[@name='guitars']").first }
    let(:fender_option)   { driver.find_xpath("//option[@id='fender']").first }
    let(:reset_button)    { driver.find_xpath("//button[@type='reset']").first }

    context "a select element's selection has been changed" do
      before do
        expect(animal_select.value).to eq "Capybara"
        monkey_option.select_option
      end

      it "returns the new selection" do
        expect(animal_select.value).to eq "Monkey"
      end

      it "does not modify the selected attribute of a new selection" do
        expect(driver.evaluate_script("arguments[0].getAttribute('selected')", monkey_option)).to be_nil
      end

      it "returns the old value when a reset button is clicked" do
        reset_button.click

        expect(animal_select.value).to eq "Capybara"
      end
    end

    context "a multi-select element's option has been unselected" do
      before do
        expect(toppings_select.value).to include("Apple", "Banana", "Cherry")

        apple_option.unselect_option
      end

      it "does not return the deselected option" do
        expect(toppings_select.value).not_to include("Apple")
      end

      it "returns the deselected option when a reset button is clicked" do
        reset_button.click

        expect(toppings_select.value).to include("Apple", "Banana", "Cherry")
      end
    end

    context "a multi-select (with empty multiple attribute) element's option has been unselected" do
      before do
        expect(guitars_select.value).to include("Fender", "Gibson")

        fender_option.unselect_option
      end

      it "does not return the deselected option" do
        expect(guitars_select.value).not_to include("Fender")
      end
    end

    it "reselects an option in a multi-select" do
      apple_option.unselect_option
      banana_option.unselect_option
      cherry_option.unselect_option

      expect(toppings_select.value).to eq []

      apple_option.select_option
      banana_option.select_option
      cherry_option.select_option

      expect(toppings_select.value).to include("Apple", "Banana", "Cherry")
    end

    let(:checked_box) { driver.find_xpath("//input[@name='checkedbox']").first }
    let(:unchecked_box) { driver.find_xpath("//input[@name='uncheckedbox']").first }

    it "knows a checked box is checked" do
      expect(checked_box['checked']).to be true
    end

    it "knows a checked box is checked using checked?" do
      expect(checked_box).to be_checked
    end

    it "knows an unchecked box is unchecked" do
      expect(unchecked_box['checked']).not_to be_truthy
    end

    it "knows an unchecked box is unchecked using checked?" do
      expect(unchecked_box).not_to be_checked
    end

    it "checks an unchecked box" do
      unchecked_box.set(true)
      expect(unchecked_box).to be_checked
    end

    it "unchecks a checked box" do
      checked_box.set(false)
      expect(checked_box).not_to be_checked
    end

    it "leaves a checked box checked" do
      checked_box.set(true)
      expect(checked_box).to be_checked
    end

    it "leaves an unchecked box unchecked" do
      unchecked_box.set(false)
      expect(unchecked_box).not_to be_checked
    end

    let(:enabled_input)  { driver.find_xpath("//input[@name='foo']").first }
    let(:disabled_input) { driver.find_xpath("//input[@id='disabled_input']").first }

    it "knows a disabled input is disabled" do
      expect(disabled_input['disabled']).to be true
    end

    it "knows a not disabled input is not disabled" do
      expect(enabled_input['disabled']).not_to be_truthy
    end

    it "does not modify a readonly input" do
      readonly_input = driver.find_css("#readonly_input").first
      readonly_input.set('enabled')
      expect(readonly_input.value).to eq 'readonly'
    end

    it "should see enabled options in disabled select as disabled" do
      expect(driver.find_css("#select-option-disabled").first).to be_disabled
    end
  end

  context "dom events" do
    let(:driver) do
      driver_for_html(<<-HTML)
        <html><body>
          <a href='#' class='watch'>Link</a>
          <ul id="events"></ul>
          <script type="text/javascript">
            var events = document.getElementById("events");
            var recordEvent = function (event) {
              var element = document.createElement("li");
              element.innerHTML = event.type;
              events.appendChild(element);
            };

            var elements = document.getElementsByClassName("watch");
            for (var i = 0; i < elements.length; i++) {
              var element = elements[i];
              element.addEventListener("mousedown", recordEvent);
              element.addEventListener("mouseup", recordEvent);
              element.addEventListener("click", recordEvent);
              element.addEventListener("dblclick", recordEvent);
              element.addEventListener("contextmenu", recordEvent);
            }
          </script>
        </body></html>
      HTML
    end

    before { visit("/") }

    let(:watch) { driver.find_xpath("//a").first }
    let(:fired_events) {  driver.find_xpath("//li").map(&:visible_text) }

    it "triggers mouse events" do
      watch.click
      expect(fired_events).to eq %w(mousedown mouseup click)
    end

    it "triggers double click" do
      # check event order at http://www.quirksmode.org/dom/events/click.html
      watch.double_click
      expect(fired_events).to eq %w(mousedown mouseup click mousedown mouseup click dblclick)
    end

    it "triggers right click" do
      watch.right_click
      expect(fired_events).to eq %w(mousedown contextmenu mouseup)
    end
  end

  context "form events app" do
    let(:driver) do
      driver_for_html(<<-HTML)
        <html><body>
          <form action="/" method="GET">
            <input class="watch" type="email"/>
            <input class="watch" type="number"/>
            <input class="watch" type="password"/>
            <input class="watch" type="search"/>
            <input class="watch" type="tel"/>
            <input class="watch" type="text" value="original"/>
            <input class="watch" type="url"/>
            <textarea class="watch"></textarea>
            <input class="watch" type="checkbox"/>
            <input class="watch" type="radio"/>
            <select id="single" class="watch">
              <option>Single Option 1</option>
              <option>Single Option 2</option>
            </select>
            <select id="multiple" class="watch" multiple="multiple">
              <option  class="watch" selected="selected">Multiple Option 1</option>
              <option  class="watch" selected="selected">Multiple Option 2</option>
              <option  class="watch">Multiple Option 3</option>
              <optgroup>
                <option  class="watch">Multiple Option 4</option>
              </optgroup>
            </select>
          </form>
          <ul id="events"></ul>
          <script type="text/javascript">
            var events = document.getElementById("events");
            var recordEvent = function (event) {
              var element = document.createElement("li");
              var event_description = "";
              if (event.target.id)
                event_description += event.target.id + '.';
              event_description += event.type;
              element.innerHTML = event_description;
              events.appendChild(element);
            };

            var elements = document.getElementsByClassName("watch");
            var watched_events = ["focus", "keydown", "keypress", "keyup", "input", "change",
                          "blur", "mousedown", "mouseup", "click"];
            for (var i = 0; i < elements.length; i++) {
              for (var j = 0; j < watched_events.length; j++) {
                elements[i].addEventListener(watched_events[j], recordEvent);
              }
            }
          </script>
        </body></html>
      HTML
    end

    def logged_events
      driver.find_xpath("//li").map(&:visible_text)
    end

    before { visit("/") }

    let(:newtext) { '12345' }

    let(:keyevents) do
      (%w{focus} +
       newtext.length.times.collect { %w{keydown keypress input keyup} }
      ).flatten
    end

    let(:textevents) { keyevents + %w(change blur) }

    %w(email number password search tel text url).each do | field_type |
      it "triggers text input events on inputs of type #{field_type}" do
        driver.find_xpath("//input[@type='#{field_type}']").first.set(newtext)
        driver.find_xpath("//body").first.click
        expect(logged_events).to eq textevents
      end
    end

    it "triggers events for cleared inputs" do
      driver.find_xpath("//input[@type='text']").first.set('')
      driver.find_xpath("//body").first.click
      expect(logged_events).to include("change")
    end

    it "triggers textarea input events" do
      driver.find_xpath("//textarea").first.set(newtext)
      expect(logged_events).to eq keyevents
    end

    it "triggers radio input events" do
      driver.find_xpath("//input[@type='radio']").first.set(true)
      expect(logged_events).to eq %w(mousedown focus mouseup change click)
    end

    it "triggers checkbox events" do
      driver.find_xpath("//input[@type='checkbox']").first.set(true)
      expect(logged_events).to eq %w(mousedown focus mouseup change click)
    end

    it "triggers select events" do
      driver.find_xpath("//option[text() = 'Single Option 2']").first.select_option
      expect(logged_events).to eq %w[single.mousedown single.focus single.input single.change single.mouseup single.click]
    end

    it "triggers correct unselect events for multiple selects" do
      driver.find_xpath("//option[text() = 'Multiple Option 2']").first.unselect_option
      expect(logged_events).to eq %w[multiple.mousedown multiple.focus multiple.input multiple.change multiple.mouseup multiple.click]
    end

    it "triggers correct unselect events for multiple selects when already unselected" do
      driver.find_xpath("//option[text() = 'Multiple Option 3']").first.unselect_option
      expect(logged_events).to eq %w[multiple.mousedown multiple.focus multiple.input multiple.mouseup multiple.click]
    end

    it "triggers correct select events for multiple selects when additional option is selected" do
      driver.find_xpath("//option[text() = 'Multiple Option 4']").first.select_option
      expect(logged_events).to eq %w[multiple.mousedown multiple.focus multiple.input multiple.change multiple.mouseup multiple.click]
    end
  end

  context "mouse app" do
    let(:driver) do
      driver_for_html(<<-HTML)
        <html>
        <head>
        <style type="text/css">
          #hover { max-width: 30em; }
          #hover span { line-height: 1.5; }
          #hover span:hover + .hidden { display: block; }
          #circle_hover:hover + .hidden { display: block; }
          .hidden { display: none; }
        </style>
        </head>
        <body>
          <div id="change">Change me</div>
          <div id="mouseup">Push me</div>
          <div id="mousedown">Release me</div>
          <div id="hover">
            <span>This really long paragraph has a lot of text and will wrap. This sentence ensures that we have four lines of text.</span>
            <div class="hidden">Text that only shows on hover.</div>
          </div>
          <svg height="200" width="300">
            <circle id="circle_hover" cx="50" cy="50" r="40" stroke="black" stroke-width="3" fill="red" />
            <text class="hidden" y="110"> Sibling that only shows when circle is hovered over.</text>
          </svg>
          <form action="/" method="GET">
            <select id="change_select" name="change_select">
              <option value="1" id="option-1" selected="selected">one</option>
              <option value="2" id="option-2">two</option>
            </select>
            <select id="change_select_in_optgroup" name="change_select_in_optgroup">
              <optgroup>
                <option value="1" id="option-in-optgroup-1" selected="selected">one</option>
                <option value="2" id="option-in-optgroup-2">two</option>
              </optgroup>
            </select>
          </form>
          <script type="text/javascript">
            document.getElementById("change_select").
              addEventListener("change", function () {
                this.className = "triggered";
              });
            document.getElementById("change_select_in_optgroup").
              addEventListener("change", function () {
                this.className = "triggered";
              });
            document.getElementById("change").
              addEventListener("change", function () {
                this.className = "triggered";
              });
            document.getElementById("mouseup").
              addEventListener("mouseup", function () {
                this.className = "triggered";
              });
            document.getElementById("mousedown").
              addEventListener("mousedown", function () {
                this.className = "triggered";
              });
          </script>
          <a href="/next">Next</a>
        </body></html>
      HTML
    end

    before { visit("/") }

    it "hovers an element" do
      expect(driver.find_css("#hover").first.visible_text).not_to match /Text that only shows on hover/
      driver.find_css("#hover span").first.hover
      expect(driver.find_css("#hover").first.visible_text).to match /Text that only shows on hover/
    end

    it "hovers an svg element" do
      # visible_text does not work for SVG elements. It returns all the text.
      expect(driver.find_css("text").first).not_to be_visible
      driver.find_css("#circle_hover").first.hover
      expect(driver.find_css("text").first).to be_visible
    end

    it "hovers an element off the screen" do
      driver.resize_window(200, 200)
      driver.evaluate_script(<<-JS)
        var element = document.getElementById('hover');
        element.style.position = 'absolute';
        element.style.left = '200px';
      JS
      expect(driver.find_css("#hover").first.visible_text).not_to match /Text that only shows on hover/
      driver.find_css("#hover span").first.hover
      expect(driver.find_css("#hover").first.visible_text).to match /Text that only shows on hover/
    end

    it "clicks an element" do
      driver.find_xpath("//a").first.click
      expect(driver.current_url).to match %r{/next$}
    end

    it "fires a mouse event" do
      driver.find_xpath("//*[@id='mouseup']").first.trigger("mouseup")
      expect(driver.find_xpath("//*[@class='triggered']")).not_to be_empty
    end

    it "fires a non-mouse event" do
      driver.find_xpath("//*[@id='change']").first.trigger("change")
      expect(driver.find_xpath("//*[@class='triggered']")).not_to be_empty
    end

    it "fires a change on select" do
      select = driver.find_xpath("//select[@id='change_select']").first
      expect(select.value).to eq "1"
      option = driver.find_xpath("//option[@id='option-2']").first
      option.select_option
      expect(select.value).to eq "2"
      expect(driver.find_xpath("//select[@id='change_select'][@class='triggered']")).not_to be_empty
    end

    it "fires a change on select when using an optgroup" do
      select = driver.find_xpath("//select[@id='change_select_in_optgroup']").first
      expect(select.value).to eq "1"
      option = driver.find_xpath("//option[@id='option-in-optgroup-2']").first
      option.select_option
      expect(select.value).to eq "2"
      expect(driver.find_xpath("//select[@id='change_select_in_optgroup'][@class='triggered']")).not_to be_empty
    end

    it "fires drag events" do
      draggable = driver.find_xpath("//*[@id='mousedown']").first
      container = driver.find_xpath("//*[@id='mouseup']").first

      draggable.drag_to(container)

      expect(driver.find_xpath("//*[@class='triggered']").size).to eq 1
    end
  end

  context "nesting app" do
    let(:driver) do
      driver_for_html(<<-HTML)
        <html><body>
          <div id="parent">
            <div class="find">Expected</div>
          </div>
          <div class="find">Unexpected</div>
        </body></html>
      HTML
    end

    before { visit("/") }

    it "evaluates nested xpath expressions" do
      parent = driver.find_xpath("//*[@id='parent']").first
      expect(parent.find_xpath("./*[@class='find']").map(&:visible_text)).to eq %w(Expected)
    end

    it "finds elements by CSS" do
      parent = driver.find_css("#parent").first
      expect(parent.find_css(".find").first.visible_text).to eq "Expected"
    end
  end

  context "slow app" do
    it "waits for a request to load" do
      result = ""
      driver = driver_for_app do
        get "/result" do
          sleep(0.5)
          result << "finished"
          ""
        end

        get "/" do
          %{<html><body><a href="/result">Go</a></body></html>}
        end
      end
      visit("/", driver)
      driver.find_xpath("//a").first.click
      expect(result).to eq "finished"
    end
  end

  context "error app" do
    let(:driver) do
      driver_for_app do
        get "/error" do
          invalid_response
        end

        get "/" do
          <<-HTML
            <html><body>
              <form action="/error"><input type="submit"/></form>
            </body></html>
          HTML
        end
      end
    end

    before { visit("/") }

    it "raises a webkit error for the requested url" do
      expect {
        driver.find_xpath("//input").first.click
        wait_for_error_to_complete
        driver.find_xpath("//body")
      }.to raise_error(Capybara::Webkit::InvalidResponseError, %r{/error})
    end

    def wait_for_error_to_complete
      sleep(0.5)
    end
  end

  context "slow error app" do
    let(:driver) do
      driver_for_app do
        get "/error" do
          sleep(1)
          invalid_response
        end

        get "/" do
          <<-HTML
            <html><body>
              <form action="/error"><input type="submit"/></form>
              <p>hello</p>
            </body></html>
          HTML
        end
      end
    end

    before { visit("/") }

    it "raises a webkit error and then continues" do
      driver.find_xpath("//input").first.click
      expect { driver.find_xpath("//p") }.to raise_error(Capybara::Webkit::InvalidResponseError)
      visit("/")
      expect(driver.find_xpath("//p").first.visible_text).to eq "hello"
    end
  end

  context "popup app" do
    let(:driver) do
      driver_for_app do
        get "/" do
          sleep(0.5)
          return <<-HTML
            <html><body>
              <script type="text/javascript">
                alert("alert");
                confirm("confirm");
                prompt("prompt");
              </script>
              <p>success</p>
            </body></html>
          HTML
        end
      end
    end

    before { visit("/") }

    it "doesn't crash from alerts" do
      expect(driver.find_xpath("//p").first.visible_text).to eq "success"
    end
  end

  context "custom header" do
    let(:driver) do
      driver_for_app do
        get "/" do
          <<-HTML
            <html><body>
              <p id="user-agent">#{env['HTTP_USER_AGENT']}</p>
              <p id="x-capybara-webkit-header">#{env['HTTP_X_CAPYBARA_WEBKIT_HEADER']}</p>
              <p id="accept">#{env['HTTP_ACCEPT']}</p>
              <a href="/">/</a>
            </body></html>
          HTML
        end
      end
    end

    before { visit("/") }

    before do
      driver.header('user-agent', 'capybara-webkit/custom-user-agent')
      driver.header('x-capybara-webkit-header', 'x-capybara-webkit-header')
      driver.header('accept', 'text/html')
      visit('/')
    end

    it "can set user_agent" do
      expect(driver.find_xpath('id("user-agent")').first.visible_text).to eq 'capybara-webkit/custom-user-agent'
      expect(driver.evaluate_script('navigator.userAgent')).to eq 'capybara-webkit/custom-user-agent'
    end

    it "keep user_agent in next page" do
      driver.find_xpath("//a").first.click
      expect(driver.find_xpath('id("user-agent")').first.visible_text).to eq 'capybara-webkit/custom-user-agent'
      expect(driver.evaluate_script('navigator.userAgent')).to eq 'capybara-webkit/custom-user-agent'
    end

    it "can set custom header" do
      expect(driver.find_xpath('id("x-capybara-webkit-header")').first.visible_text).to eq 'x-capybara-webkit-header'
    end

    it "can set Accept header" do
      expect(driver.find_xpath('id("accept")').first.visible_text).to eq 'text/html'
    end

    it "can reset all custom header" do
      driver.reset!
      visit('/')
      expect(driver.find_xpath('id("user-agent")').first.visible_text).not_to eq 'capybara-webkit/custom-user-agent'
      expect(driver.evaluate_script('navigator.userAgent')).not_to eq 'capybara-webkit/custom-user-agent'
      expect(driver.find_xpath('id("x-capybara-webkit-header")').first.visible_text).to be_empty
      expect(driver.find_xpath('id("accept")').first.visible_text).not_to eq 'text/html'
    end
  end

  context "no response app" do
    let(:driver) do
      driver_for_html(<<-HTML)
        <html><body>
          <form action="/error"><input type="submit"/></form>
        </body></html>
      HTML
    end

    let!(:connection) { fork_connection }
    before { visit("/") }

    it "raises a webkit error for the requested url" do
      make_the_server_go_away
      expect {
        driver.find_xpath("//body")
      }.to raise_error(Capybara::Webkit::NoResponseError, %r{response})
      make_the_server_come_back
    end

    def make_the_server_come_back
      [:gets, :puts, :print].each { |msg| allow(connection).to receive(msg).and_call_original }
    end

    def make_the_server_go_away
      allow(connection).to receive(:gets).and_return(nil)
      allow(connection).to receive(:puts).and_return(nil)
      allow(connection).to receive(:print).and_return(nil)
    end
  end

  context "custom font app" do
    let(:driver) do
      driver_for_html(<<-HTML)
        <html>
          <head>
            <style type="text/css">
              p { font-family: "Verdana"; }
              p:before { font-family: "Verdana"; }
              p:after { font-family: "Verdana"; }
            </style>
          </head>
          <body>
            <p id="text">Hello</p>
          </body>
        </html>
      HTML
    end

    before { visit("/") }

    let(:font_family) do
      driver.evaluate_script(<<-SCRIPT)
        var element = document.getElementById("text");
        element.ownerDocument.defaultView.getComputedStyle(element, null).getPropertyValue("font-family");
      SCRIPT
    end

    it "ignores custom fonts" do
      skip "font replacement not needed for QT >= 5" unless driver.version =~ /Qt: 4/
      expect(font_family).to eq "Arial"
    end

    it "ignores custom fonts before an element" do
      skip "font replacement not needed for QT >= 5" unless driver.version =~ /Qt: 4/
      expect(font_family).to eq "Arial"
    end

    it "ignores custom fonts after an element" do
      skip "font replacement not needed for QT >= 5" unless driver.version =~ /Qt: 4/
      expect(font_family).to eq "Arial"
    end
  end

  context "cookie-based app" do
    let(:driver) do
      driver_for_app do
        get "/" do
          headers 'Set-Cookie' => 'cookie=abc; domain=127.0.0.1; path=/'
          <<-HTML
            <html><body>
              <p id="cookie">#{request.cookies["cookie"] || ""}</p>
            </body></html>
          HTML
        end
      end
    end

    before { visit("/") }

    def echoed_cookie
      driver.find_xpath('id("cookie")').first.visible_text
    end

    it "remembers the cookie on second visit" do
      expect(echoed_cookie).to eq ""
      visit "/"
      expect(echoed_cookie).to eq "abc"
    end

    it "uses a custom cookie" do
      driver.set_cookie 'cookie=abc; domain=127.0.0.1; path=/'
      visit "/"
      expect(echoed_cookie).to eq "abc"
    end

    it "clears cookies" do
      driver.clear_cookies
      visit "/"
      expect(echoed_cookie).to eq ""
    end

    it "allows reading cookies" do
      expect(driver.cookies["cookie"]).to eq "abc"
      expect(driver.cookies.find("cookie").path).to eq "/"
      expect(driver.cookies.find("cookie").domain).to include "127.0.0.1"
    end
  end

  context "remove node app" do
    let(:driver) do
      driver_for_html(<<-HTML)
        <html>
          <div id="parent">
            <p id="removeMe">Hello</p>
          </div>
        </html>
      HTML
    end

    before { visit("/") }

    before { set_automatic_reload false }
    after { set_automatic_reload true }

    def set_automatic_reload(value)
      if Capybara.respond_to?(:automatic_reload)
        Capybara.automatic_reload = value
      end
    end

    it "allows removed nodes when reloading is disabled" do
      node = driver.find_xpath("//p[@id='removeMe']").first
      driver.evaluate_script("document.getElementById('parent').innerHTML = 'Magic'")
      expect(node.visible_text).to eq 'Hello'
    end
  end

  context "app with a lot of HTML tags" do
    let(:driver) do
      driver_for_html(<<-HTML)
        <html>
          <head>
            <title>My eBook</title>
            <meta class="charset" name="charset" value="utf-8" />
            <meta class="author" name="author" value="Firstname Lastname" />
          </head>
          <body>
            <div id="toc">
              <table>
                <thead id="head">
                  <tr><td class="td1">Chapter</td><td>Page</td></tr>
                </thead>
                <tbody>
                  <tr><td>Intro</td><td>1</td></tr>
                  <tr><td>Chapter 1</td><td class="td2">1</td></tr>
                  <tr><td>Chapter 2</td><td>1</td></tr>
                </tbody>
              </table>
            </div>

            <h1 class="h1">My first book</h1>
            <p class="p1">Written by me</p>
            <div id="intro" class="intro">
              <p>Let's try out XPath</p>
              <p class="p2">in capybara-webkit</p>
            </div>

            <h2 class="chapter1">Chapter 1</h2>
            <p>This paragraph is fascinating.</p>
            <p class="p3">But not as much as this one.</p>

            <h2 class="chapter2">Chapter 2</h2>
            <p>Let's try if we can select this</p>
          </body>
        </html>
      HTML
    end

    before { visit("/") }

    it "builds up node paths correctly" do
      cases = {
        "//*[contains(@class, 'author')]"    => "/html/head/meta[2]",
        "//*[contains(@class, 'td1')]"       => "/html/body/div[@id='toc']/table/thead[@id='head']/tr/td[1]",
        "//*[contains(@class, 'td2')]"       => "/html/body/div[@id='toc']/table/tbody/tr[2]/td[2]",
        "//h1"                               => "/html/body/h1",
        "//*[contains(@class, 'chapter2')]"  => "/html/body/h2[2]",
        "//*[contains(@class, 'p1')]"        => "/html/body/p[1]",
        "//*[contains(@class, 'p2')]"        => "/html/body/div[@id='intro']/p[2]",
        "//*[contains(@class, 'p3')]"        => "/html/body/p[3]",
      }

      cases.each do |xpath, path|
        nodes = driver.find_xpath(xpath)
        expect(nodes.size).to eq 1
        expect(nodes[0].path).to eq path
      end
    end
  end

  context "css overflow app" do
    let(:driver) do
      driver_for_html(<<-HTML)
        <html>
          <head>
            <style type="text/css">
              #overflow { overflow: hidden }
            </style>
          </head>
          <body>
            <div id="overflow">Overflow</div>
          </body>
        </html>
      HTML
    end

    before { visit("/") }

    it "handles overflow hidden" do
      expect(driver.find_xpath("//div[@id='overflow']").first.visible_text).to eq "Overflow"
    end
  end

  context "javascript redirect app" do
    let(:driver) do
      driver_for_app do
        get '/redirect' do
          <<-HTML
            <html>
              <script type="text/javascript">
                window.location = "/";
              </script>
            </html>
          HTML
        end

        get '/' do
          "<html><p>finished</p></html>"
        end
      end
    end

    it "loads a page without error" do
      10.times do
        visit("/redirect")
        expect(driver.find_xpath("//p").first.visible_text).to eq "finished"
      end
    end
  end

  context "localStorage works" do
    let(:driver) do
      driver_for_html(<<-HTML)
        <html>
          <body>
            <span id='output'></span>
            <script type="text/javascript">
              if (typeof localStorage !== "undefined") {
                if (!localStorage.refreshCounter) {
                  localStorage.refreshCounter = 0;
                }
                if (localStorage.refreshCounter++ > 0) {
                  document.getElementById("output").innerHTML = "localStorage is enabled";
                }
              }
            </script>
          </body>
        </html>
      HTML
    end

    before { visit("/") }

    it "displays the message on subsequent page loads" do
      expect(driver.find_xpath("//span[contains(.,'localStorage is enabled')]")).to be_empty
      visit "/"
      expect(driver.find_xpath("//span[contains(.,'localStorage is enabled')]")).not_to be_empty
    end

    it "clears the message after a driver reset!" do
      visit "/"
      expect(driver.find_xpath("//span[contains(.,'localStorage is enabled')]")).not_to be_empty
      driver.reset!
      visit "/"
      expect(driver.find_xpath("//span[contains(.,'localStorage is enabled')]")).to be_empty
    end
  end

  context "caching app" do
    let(:driver) do
      etag_value = SecureRandom.hex

      driver_for_app do
        get '/' do
          etag etag_value
          <<-HTML
            <html>
              <body>
                Expected body
              </body>
            </html>
          HTML
        end
      end
    end

    it "returns a body for cached responses" do
      visit '/'
      first = driver.html
      visit '/'
      second = driver.html
      expect(second).to eq(first)
    end
  end

  context "offline application cache" do
    let(:driver) do
      @visited = []
      visited = @visited

      driver_for_app do
        get '/8d853f09-4275-409d-954d-ebbf6e2ce732' do
          content_type 'text/cache-manifest'
          visited << 'manifest'
          <<-TEXT
CACHE MANIFEST
/4aaffa31-f42d-403e-a19e-6b248d608087
          TEXT
        end

        # UUID urls so that this gets isolated from other tests
        get '/f8742c39-8bef-4196-b1c3-80f8a3d65f3e' do
          visited << 'complex'
          <<-HTML
            <html manifest="/8d853f09-4275-409d-954d-ebbf6e2ce732">
              <body>
                <span id='state'></span>
                <span id='finished'></span>
                <script type="text/javascript">
                  document.getElementById("state").innerHTML = applicationCache.status;
                  applicationCache.addEventListener('cached', function() {
                    document.getElementById("finished").innerHTML = 'cached';
                  });
                  applicationCache.addEventListener('error', function() {
                    document.getElementById("finished").innerHTML = 'error';
                  });
                </script>
              </body>
            </html>
          HTML
        end

        get '/4aaffa31-f42d-403e-a19e-6b248d608087' do
          visited << 'simple'
          <<-HTML
            <html manifest="/8d853f09-4275-409d-954d-ebbf6e2ce732">
              <body>
              </body>
            </html>
          HTML
        end
      end
    end

    before { visit("/f8742c39-8bef-4196-b1c3-80f8a3d65f3e") }

    it "has proper state available" do
      expect(driver.find_xpath("//*[@id='state']").first.visible_text).to eq '0'
      sleep 1
      expect(@visited).to eq(['complex', 'manifest', 'simple']), 'files were not downloaded in expected order'
      expect(driver.find_xpath("//*[@id='finished']").first.visible_text).to eq 'cached'
    end

    it "is cleared on driver reset!" do
      sleep 1
      expect(@visited).to eq(['complex', 'manifest', 'simple']), 'files were not downloaded in expected order'
      driver.reset!
      @visited.clear
      visit '/4aaffa31-f42d-403e-a19e-6b248d608087'
      sleep 1
      expect(@visited).to eq(['simple', 'manifest', 'simple']), 'simple action was used from cache instead of server'
    end
  end

  context "form app with server-side handler" do
    let(:driver) do
      driver_for_app do
        post "/" do
          "<html><body><p>Congrats!</p></body></html>"
        end

        get "/" do
          <<-HTML
            <html>
              <head><title>Form</title>
              <body>
                <form action="/" method="POST">
                  <input type="hidden" name="abc" value="123" />
                  <input type="submit" value="Submit" />
                </form>
              </body>
            </html>
          HTML
        end
      end
    end

    before { visit("/") }

    it "submits a form without clicking" do
      driver.find_xpath("//form")[0].submit
      expect(driver.html).to include "Congrats"
    end
  end

  def driver_for_key_body(event)
    driver_for_app do
      get "/" do
        <<-HTML
          <html>
            <head><title>Form</title></head>
            <body>
              <div id="charcode_value"></div>
              <div id="keycode_value"></div>
              <div id="which_value"></div>
              <input type="text" id="charcode" name="charcode" on#{event}="setcharcode" />
              <script type="text/javascript">
                var element = document.getElementById("charcode")
                element.addEventListener("#{event}", setcharcode);
                function setcharcode(event) {
                  var element = document.getElementById("charcode_value");
                  element.innerHTML = event.charCode;
                  element = document.getElementById("keycode_value");
                  element.innerHTML = event.keyCode;
                  element = document.getElementById("which_value");
                  element.innerHTML = event.which;
                }
              </script>
            </body>
          </html>
        HTML
      end
    end
  end

  def charCode_for(character)
    driver.find_xpath("//input")[0].set(character)
    driver.find_xpath("//div[@id='charcode_value']")[0].visible_text
  end

  def keyCode_for(character)
    driver.find_xpath("//input")[0].set(character)
    driver.find_xpath("//div[@id='keycode_value']")[0].visible_text
  end

  def which_for(character)
    driver.find_xpath("//input")[0].set(character)
    driver.find_xpath("//div[@id='which_value']")[0].visible_text
  end

  context "keypress app" do
    let(:driver) { driver_for_key_body "keypress" }

    before { visit("/") }

    it "returns the charCode for the keypressed" do
      expect(charCode_for("a")).to eq "97"
      expect(charCode_for("A")).to eq "65"
      expect(charCode_for("\r")).to eq "13"
      expect(charCode_for(",")).to eq "44"
      expect(charCode_for("<")).to eq "60"
      expect(charCode_for("0")).to eq "48"
    end

    it "returns the keyCode for the keypressed" do
      expect(keyCode_for("a")).to eq "97"
      expect(keyCode_for("A")).to eq "65"
      expect(keyCode_for("\r")).to eq "13"
      expect(keyCode_for(",")).to eq "44"
      expect(keyCode_for("<")).to eq "60"
      expect(keyCode_for("0")).to eq "48"
    end

    it "returns the which for the keypressed" do
      expect(which_for("a")).to eq "97"
      expect(which_for("A")).to eq "65"
      expect(which_for("\r")).to eq "13"
      expect(which_for(",")).to eq "44"
      expect(which_for("<")).to eq "60"
      expect(which_for("0")).to eq "48"
    end
  end

  shared_examples "a keyupdown app" do
    it "returns a 0 charCode for the event" do
      expect(charCode_for("a")).to eq "0"
      expect(charCode_for("A")).to eq "0"
      expect(charCode_for("\b")).to eq "0"
      expect(charCode_for(",")).to eq "0"
      expect(charCode_for("<")).to eq "0"
      expect(charCode_for("0")).to eq "0"
    end

    it "returns the keyCode for the event" do
      expect(keyCode_for("a")).to eq "65"
      expect(keyCode_for("A")).to eq "65"
      expect(keyCode_for("\b")).to eq "8"
      expect(keyCode_for(",")).to eq "188"
      expect(keyCode_for("<")).to eq "188"
     expect( keyCode_for("0")).to eq "48"
    end

    it "returns the which for the event" do
      expect(which_for("a")).to eq "65"
      expect(which_for("A")).to eq "65"
      expect(which_for("\b")).to eq "8"
      expect(which_for(",")).to eq "188"
      expect(which_for("<")).to eq "188"
      expect(which_for("0")).to eq "48"
    end
  end

  context "keydown app" do
    let(:driver) { driver_for_key_body "keydown" }
    before { visit("/") }
    it_behaves_like "a keyupdown app"
  end

  context "keyup app" do
    let(:driver) { driver_for_key_body "keyup" }
    before { visit("/") }
    it_behaves_like "a keyupdown app"
  end

  context "javascript new window app" do
    let(:driver) do
      driver_for_app do
        get '/new_window' do
          <<-HTML
            <html>
              <script type="text/javascript">
                window.open('http://#{request.host_with_port}/?#{request.query_string}', 'myWindow');
              </script>
              <p>bananas</p>
            </html>
          HTML
        end

        get "/" do
          sleep params['sleep'].to_i if params['sleep']
          "<html><head><title>My New Window</title></head><body><p>finished</p></body></html>"
        end
      end
    end

    before { visit("/") }

    it "has the expected text in the new window" do
      visit("/new_window")
      driver.within_window(driver.window_handles.last) do
        expect(driver.find_xpath("//p").first.visible_text).to eq "finished"
      end
    end

    it "can switch to another window" do
      visit("/new_window")
      driver.switch_to_window(driver.window_handles.last)
      expect(driver.find_xpath("//p").first.visible_text).to eq "finished"
    end

    it "knows the current window handle" do
      visit("/new_window")
      driver.within_window(driver.window_handles.last) do
        expect(driver.current_window_handle).to eq driver.window_handles.last
      end
    end

    it "can close the current window" do
      visit("/new_window")
      original_handle = driver.current_window_handle
      driver.switch_to_window(driver.window_handles.last)
      driver.close_window(driver.current_window_handle)

      expect(driver.current_window_handle).to eq(original_handle)
    end

    it "can close an unfocused window" do
      visit("/new_window")
      driver.close_window(driver.window_handles.last)
      expect(driver.window_handles.size).to eq(1)
    end

    it "can close the last window" do
      visit("/new_window")
      handles = driver.window_handles
      handles.each { |handle| driver.close_window(handle) }
      expect(driver.html).to be_empty
      expect(handles).not_to include(driver.current_window_handle)
    end

    it "waits for the new window to load" do
      visit("/new_window?sleep=1")
      driver.within_window(driver.window_handles.last) do
        expect(driver.find_xpath("//p").first.visible_text).to eq "finished"
      end
    end

    it "waits for the new window to load when the window location has changed" do
      visit("/new_window?sleep=2")
      driver.execute_script("setTimeout(function() { window.location = 'about:blank' }, 1000)")
      driver.within_window(driver.window_handles.last) do
        expect(driver.find_xpath("//p").first.visible_text).to eq "finished"
      end
    end

    it "switches back to the original window" do
      visit("/new_window")
      driver.within_window(driver.window_handles.last) { }
      expect(driver.find_xpath("//p").first.visible_text).to eq "bananas"
    end

    it "supports finding a window by name" do
      visit("/new_window")
      driver.within_window('myWindow') do
        expect(driver.find_xpath("//p").first.visible_text).to eq "finished"
      end
    end

    it "supports finding a window by title" do
      visit("/new_window?sleep=5")
      driver.within_window('My New Window') do
        expect(driver.find_xpath("//p").first.visible_text).to eq "finished"
      end
    end

    it "supports finding a window by url" do
      visit("/new_window?test")
      driver.within_window(driver_url(driver, "/?test")) do
        expect(driver.find_xpath("//p").first.visible_text).to eq "finished"
      end
    end

    it "raises an error if the window is not found" do
      expect { driver.within_window('myWindowDoesNotExist') }.to raise_error(Capybara::Webkit::NoSuchWindowError)
    end

    it "has a number of window handles equal to the number of open windows" do
      expect(driver.window_handles.size).to eq 1
      visit("/new_window")
      expect(driver.window_handles.size).to eq 2
    end

    it "removes windows when closed via JavaScript" do
      visit("/new_window")
      driver.execute_script('console.log(window.document.title); window.close()')
      sleep 2
      expect(driver.window_handles.size).to eq 1
    end

    it "closes new windows on reset" do
      visit("/new_window")
      last_handle = driver.window_handles.last
      driver.reset!
      expect(driver.window_handles).not_to include(last_handle)
    end

    it "leaves the old window focused when opening a new window" do
      visit("/new_window")
      current_window = driver.current_window_handle
      driver.open_new_window

      expect(driver.current_window_handle).to eq current_window
      expect(driver.window_handles.size).to eq 3
    end

    it "opens blank windows" do
      visit("/new_window")
      driver.open_new_window
      driver.switch_to_window(driver.window_handles.last)
      expect(driver.html).to be_empty
    end
  end

  it "preserves cookies across windows" do
    session_id = '12345'
    driver = driver_for_app do
      get '/new_window' do
        <<-HTML
          <html>
            <script type="text/javascript">
              window.open('http://#{request.host_with_port}/set_cookie');
            </script>
          </html>
        HTML
      end

      get '/set_cookie' do
        response.set_cookie 'session_id', session_id
      end
    end

    visit("/new_window", driver)
    expect(driver.cookies['session_id']).to eq session_id
  end

  context "timers app" do
    let(:driver) do
      driver_for_app do
        get "/success" do
          '<html><body></body></html>'
        end

        get "/not-found" do
          404
        end

        get "/outer" do
          <<-HTML
            <html>
              <head>
                <script>
                  function emit_true_load_finished(){var divTag = document.createElement("div");divTag.innerHTML = "<iframe src='/success'></iframe>";document.body.appendChild(divTag);};
                  function emit_false_load_finished(){var divTag = document.createElement("div");divTag.innerHTML = "<iframe src='/not-found'></iframe>";document.body.appendChild(divTag);};
                  function emit_false_true_load_finished() { emit_false_load_finished(); setTimeout('emit_true_load_finished()',100); };
                </script>
              </head>
              <body onload="setTimeout('emit_false_true_load_finished()',100)">
              </body>
            </html>
          HTML
        end

        get '/' do
          "<html><body></body></html>"
        end
      end
    end

    before { visit("/") }

    it "raises error for any loadFinished failure" do
      expect do
        visit("/outer")
        sleep 1
        driver.find_xpath("//body")
      end.to raise_error(Capybara::Webkit::InvalidResponseError)
    end
  end

  describe "basic auth" do
    let(:driver) do
      driver_for_app do
        get "/" do
          if env["HTTP_AUTHORIZATION"] == "Basic #{Base64.encode64("user:password").strip}"
            env["HTTP_AUTHORIZATION"]
          else
            headers "WWW-Authenticate" => 'Basic realm="Secure Area"'
            status 401
            "401 Unauthorized."
          end
        end

        get "/reset" do
          headers "WWW-Authenticate" => 'Basic realm="Secure Area"'
          status 401
          "401 Unauthorized."
        end
      end
    end

    before do
      visit('/reset')
    end

    it "can authenticate a request" do
      driver.authenticate('user', 'password')
      visit("/")
      expect(driver.html).to include("Basic "+Base64.encode64("user:password").strip)
    end

    it "returns 401 for incorrectly authenticated request" do
      driver.authenticate('user1', 'password1')
      expect { visit("/") }.not_to raise_error
      expect(driver.status_code).to eq 401
    end

    it "returns 401 for unauthenticated request" do
      expect { visit("/") }.not_to raise_error
      expect(driver.status_code).to eq 401
    end

    it "can be reset with subsequent authenticate call", skip_on_qt4: true do
      driver.authenticate('user', 'password')
      visit("/")
      expect(driver.html).to include("Basic "+Base64.encode64("user:password").strip)
      driver.authenticate('user1', 'password1')
      expect{ visit("/") }.not_to raise_error
      expect(driver.status_code).to eq 401
    end
  end

  describe "url blacklisting", skip_if_offline: true do
    let(:driver) do
      driver_for_app do
        get "/" do
          <<-HTML
          <html>
            <body>
              <script src="/script"></script>
              <iframe src="http://example.com/path" id="frame1"></iframe>
              <iframe src="http://example.org/path/to/file" id="frame2"></iframe>
              <iframe src="/frame" id="frame3"></iframe>
              <iframe src="http://example.org/foo/bar" id="frame4"></iframe>
            </body>
          </html>
          HTML
        end

        get "/frame" do
          <<-HTML
          <html>
            <body>
              <p>Inner</p>
            </body>
          </html>
          HTML
        end

        get "/script" do
          <<-JS
          document.write('<p>Script Run</p>')
          JS
        end
      end
    end

    before do
      configure do |config|
        config.block_url "http://example.org/path/to/file"
        config.block_url "http://example.*/foo/*"
        config.block_url "http://example.com"
        config.block_url "#{AppRunner.app_host}/script"
      end
    end

    it "should not fetch urls blocked by host" do
      visit("/")
      driver.within_frame('frame1') do
        expect(driver.find_xpath("//body").first.visible_text).to be_empty
      end
    end

    it "should not fetch urls blocked by path" do
      visit('/')
      driver.within_frame('frame2') do
        expect(driver.find_xpath("//body").first.visible_text).to be_empty
      end
    end

    it "should not fetch blocked scripts" do
      visit("/")
      expect(driver.html).not_to include("Script Run")
    end

    it "should fetch unblocked urls" do
      visit('/')
      driver.within_frame('frame3') do
        expect(driver.find_xpath("//p").first.visible_text).to eq "Inner"
      end
    end

    it "should not fetch urls blocked by wildcard match" do
      visit('/')
      driver.within_frame('frame4') do
        expect(driver.find("//body").first.text).to be_empty
      end
    end

    it "returns a status code for blocked urls" do
      visit("/")
      driver.within_frame('frame1') do
        expect(driver.status_code).to eq 200
      end
    end
  end

  describe "url whitelisting", skip_if_offline: true do
    it_behaves_like "output writer" do
      let(:driver) do
        driver_for_html(<<-HTML)
          <<-HTML
            <html>
              <body>
                <iframe src="http://example.com/path" id="frame"></iframe>
                <iframe src="http://www.example.com" id="frame2"></iframe>
                <iframe src="data:text/plain,Hello"></iframe>
              </body>
            </html>
        HTML
      end

      it "prints a warning for remote requests by default" do
        visit("/")

        expect(stderr).to include("http://example.com/path")
        expect(stderr).not_to include(driver.current_url)
      end

      it "can allow specific hosts" do
        configure do |config|
          config.allow_url("example.com")
          config.allow_url("www.example.com")
        end

        visit("/")

        expect(stderr).not_to include("http://example.com/path")
        expect(stderr).not_to include(driver.current_url)
        driver.within_frame("frame") do
          expect(driver.find("//body").first.text).not_to be_empty
        end
      end

      it "can allow all hosts" do
        configure(&:allow_unknown_urls)
        visit("/")

        expect(stderr).not_to include("http://example.com/path")
        expect(stderr).not_to include(driver.current_url)
        driver.within_frame("frame") do
          expect(driver.find("//body").first.text).not_to be_empty
        end
      end

      it "resets allowed hosts on reset" do
        driver.allow_unknown_urls
        driver.reset!
        visit("/")

        expect(stderr).to include("http://example.com/path")
        expect(stderr).not_to include(driver.current_url)
      end

      it "can block unknown hosts" do
        configure(&:block_unknown_urls)
        visit("/")

        expect(stderr).not_to include("http://example.com/path")
        expect(stderr).not_to include(driver.current_url)
        driver.within_frame("frame") do
          expect(driver.find("//body").first.text).to be_empty
        end
      end

      it "can allow urls with wildcards" do
        configure { |config| config.allow_url("*/path") }
        visit("/")

        expect(stderr).to include("www.example.com")
        expect(stderr).not_to include("example.com/path")
        expect(stderr).not_to include(driver.current_url)
      end

      it "whitelists localhost on reset" do
        driver.reset!

        visit("/")

        expect(stderr).not_to include(driver.current_url)
      end

      it "does not print a warning for data URIs" do
        visit("/")

        expect(stderr).not_to include('Request to unknown URL: data:text/plain')
      end
    end
  end

  describe "timeout for long requests" do
    let(:driver) do
      driver_for_app do
        html = <<-HTML
            <html>
              <body>
                <form action="/form" method="post">
                  <input type="submit" value="Submit"/>
                </form>
              </body>
            </html>
        HTML

        get "/" do
          sleep(2)
          html
        end

        post "/form" do
          sleep(4)
          html
        end
      end
    end

    it "should not raise a timeout error when zero" do
      configure { |config| config.timeout = 0 }
      expect{ visit("/") }.not_to raise_error
    end

    it "should raise a timeout error" do
      configure { |config| config.timeout = 1 }
      expect{ visit("/") }.to raise_error(Timeout::Error, "Request timed out after 1 second(s)")
    end

    it "should not raise an error when the timeout is high enough" do
      configure { |config| config.timeout = 10 }
      expect { visit("/") }.not_to raise_error
    end

    it "should set the timeout for each request" do
      configure { |config| config.timeout = 10 }
      expect{ visit("/") }.not_to raise_error
      driver.timeout = 1
      expect{ visit("/") }.to raise_error(Timeout::Error)
    end

    it "should set the timeout for each request" do
      configure { |config| config.timeout = 1 }
      expect { visit("/") }.to raise_error(Timeout::Error)
      driver.reset!
      driver.timeout = 10
      expect{ visit("/") }.not_to raise_error
    end

    it "should raise a timeout on a slow form" do
      configure { |config| config.timeout = 3 }
      visit("/")
      expect(driver.status_code).to eq 200
      driver.timeout = 1
      driver.find_xpath("//input").first.click
      expect { driver.status_code }.to raise_error(Timeout::Error)
    end

    it "get timeout" do
      configure { |config| config.timeout = 10 }
      expect(driver.browser.timeout).to eq 10
    end
  end

  describe "logger app" do
    it_behaves_like "output writer" do
      let(:driver) do
        driver_for_html("<html><body>Hello</body></html>")
      end

      it "logs nothing in normal mode" do
        configure { |config| config.debug = false }
        visit("/")
        expect(stderr).not_to include logging_message
      end

      it "logs its commands in debug mode" do
        configure { |config| config.debug = true }
        visit("/")
        expect(stderr).to include logging_message
      end

      let(:logging_message) { 'Wrote response true' }
    end
  end

  context "synchronous ajax app" do
    let(:driver) do
      driver_for_app do
        get '/' do
          <<-HTML
            <html>
            <body>
            <form id="theForm">
            <input type="submit" value="Submit" />
            </form>
            <script>
              document.getElementById('theForm').onsubmit = function() {
                xhr = new XMLHttpRequest();
                xhr.open('POST', '/', false);
                xhr.setRequestHeader('Content-Type', 'text/plain');
                xhr.send('hello');
                console.log(xhr.response);
                return false;
              }
            </script>
            </body>
            </html>
          HTML
        end

        post '/' do
          request.body.read
        end
      end
    end

    it 'should not hang the server' do
      visit('/')
      driver.find_xpath('//input').first.click
      expect(driver.console_messages.first[:message]).to eq "hello"
    end
  end

  context 'path' do
    let(:driver) do
      driver_for_html(<<-HTML)
        <html>
          <body>
            <div></div>
            <div><div><span>hello</span></div></div>
          </body>
        </html>
      HTML
    end

    it 'returns an xpath for the current node' do
      visit('/')
      path = driver.find_xpath('//span').first.path
      expect(driver.find_xpath(path).first.text).to eq 'hello'
    end
  end

  context 'unattached node app' do
    let(:driver) do
      driver_for_html(<<-HTML)
        <html><body>
        <p id="remove-me">Remove me</p>
        <a href="#" id="remove-button">remove</a>
        <script type="text/javascript">
        document.getElementById('remove-button').addEventListener('click', function() {
          var p = document.getElementById('remove-me');
          p.parentNode.removeChild(p);
        });
        </script>
        </body></html>
      HTML
    end

    it 'raises NodeNotAttachedError' do
      visit '/'
      remove_me = driver.find_css('#remove-me').first
      expect(remove_me).not_to be_nil
      driver.find_css('#remove-button').first.click
      expect { remove_me.text }.to raise_error(Capybara::Webkit::NodeNotAttachedError)
    end

    it 'raises NodeNotAttachedError if the argument node is unattached' do
      visit '/'
      remove_me = driver.find_css('#remove-me').first
      expect(remove_me).not_to be_nil
      remove_button = driver.find_css('#remove-button').first
      expect(remove_button).not_to be_nil
      remove_button.click
      expect { remove_button == remove_me }.to raise_error(Capybara::Webkit::NodeNotAttachedError)
      expect { remove_me == remove_button }.to raise_error(Capybara::Webkit::NodeNotAttachedError)
    end
  end

  context "version" do
    let(:driver) do
      driver_for_html(<<-HTML)
        <html><body></body></html>
      HTML
    end

    before { visit("/") }

    it "includes Capybara, capybara-webkit, Qt, and WebKit versions" do
      result = driver.version
      expect(result).to include("Capybara: #{Capybara::VERSION}")
      expect(result).to include("capybara-webkit: #{Capybara::Driver::Webkit::VERSION}")
      expect(result).to match /Qt: \d+\.\d+\.\d+/
      expect(result).to match /WebKit: \d+\.\d+/
      expect(result).to match /QtWebKit: \d+\.\d+/
    end
  end

  context "history" do
    let(:driver) do
      driver_for_app do
        get "/:param" do |param|
          <<-HTML
            <html>
              <body>
                <p>#{param}</p>
                <a href="/navigated">Navigate</a>
              </body>
            </html>
          HTML
        end
      end
    end

    it "can navigate in history" do
      visit("/first")
      expect(driver.find_xpath("//p").first.text).to eq('first')
      driver.find_xpath("//a").first.click
      expect(driver.find_xpath("//p").first.text).to eq('navigated')
      driver.go_back
      expect(driver.find_xpath("//p").first.text).to eq('first')
      driver.go_forward
      expect(driver.find_xpath("//p").first.text).to eq('navigated')
    end
  end

  context "response header contains colon" do
    let(:driver) do
      driver_for_app do
        get "/" do
          headers "Content-Disposition" => 'filename="File: name.txt"'
        end
      end
    end

    it "sets the response header" do
      visit("/")

      expect(
        driver.response_headers["Content-Disposition"]
      ).to eq 'filename="File: name.txt"'
    end
  end

  context "with unfinished responses" do
    it_behaves_like "output writer" do
      let(:driver) do
        count = 0
        driver_for_app do
          get "/" do
            count += 1
            <<-HTML
              <html>
                <body>
                  <script type="text/javascript">
                    setTimeout(function () {
                      xhr = new XMLHttpRequest();
                      xhr.open('GET', '/async?#{count}', true);
                      xhr.setRequestHeader('Content-Type', 'text/plain');
                      xhr.send();
                    }, 50);
                  </script>
                </body>
              </html>
            HTML
          end

          get "/async" do
            sleep 2
            ""
          end
        end
      end

      it "aborts unfinished responses" do
        driver.enable_logging
        visit "/"
        sleep 0.5
        visit "/"
        sleep 0.5
        driver.reset!
        expect(stderr).to abort_request_to("/async?2")
        expect(stderr).not_to abort_request_to("/async?1")
      end

      def abort_request_to(path)
        include(%{Aborting request to "#{url(path)}"})
      end
    end
  end

  context "when the driver process crashes" do
    let(:driver) do
      driver_for_app do
        get "/" do
          "<html><body>Relaunched</body></html>"
        end
      end
    end

    it "reports and relaunches on reset", skip_on_windows: true, skip_on_jruby: true do
      connection = fork_connection
      Process.kill "KILL", connection.pid
      expect { driver.reset! }.to raise_error(Capybara::Webkit::CrashError)
      visit "/"
      expect(driver.html).to include("Relaunched")
    end
  end

  context "handling of SSL validation errors" do
    before do
      # set up minimal HTTPS server
      @host = "127.0.0.1"
      @server = TCPServer.new(@host, 0)
      @port = @server.addr[1]

      # set up SSL layer
      ssl_serv = OpenSSL::SSL::SSLServer.new(@server, $openssl_self_signed_ctx)

      @server_thread = Thread.new(ssl_serv) do |serv|
        while conn = serv.accept do
          # read request
          request = []
          until (line = conn.readline.strip).empty?
            request << line
          end

          # write response
          html = "<html><body>D'oh!</body></html>"
          conn.write "HTTP/1.1 200 OK\r\n"
          conn.write "Content-Type:text/html\r\n"
          conn.write "Content-Length: %i\r\n" % html.size
          conn.write "\r\n"
          conn.write html
          conn.close
        end
      end

      fork_connection
    end

    after do
      @server_thread.kill
      @server.close
    end

    context "with default settings" do
      it "doesn't accept a self-signed certificate" do
        expect { driver.visit "https://#{@host}:#{@port}/" }.to raise_error(Capybara::Webkit::InvalidResponseError)
      end

      it "doesn't accept a self-signed certificate in a new window" do
        driver.execute_script("window.open('about:blank')")
        driver.switch_to_window(driver.window_handles.last)
        expect { driver.visit "https://#{@host}:#{@port}/" }.to raise_error(Capybara::Webkit::InvalidResponseError)
      end
    end

    context "ignoring SSL errors" do
      it "accepts a self-signed certificate if configured to do so" do
        configure(&:ignore_ssl_errors)
        driver.visit "https://#{@host}:#{@port}/"
      end

      it "accepts a self-signed certificate in a new window when configured" do
        configure(&:ignore_ssl_errors)
        driver.execute_script("window.open('about:blank')")
        driver.switch_to_window(driver.window_handles.last)
        driver.visit "https://#{@host}:#{@port}/"
      end
    end

    let(:driver) { driver_for_html("") }
  end

  context "skip image loading" do
    let(:driver) do
      driver_for_app do
        requests = []

        get "/" do
          <<-HTML
            <html>
              <head>
                <style>
                  body {
                    background-image: url(/path/to/bgimage);
                  }
                </style>
              </head>
              <body>
                <img src="/path/to/image"/>
              </body>
            </html>
          HTML
        end

        get "/requests" do
          <<-HTML
            <html>
              <body>
                #{requests.map { |path| "<p>#{path}</p>" }.join}
              </body>
            </html>
          HTML
        end

        get %r{/path/to/(.*)} do |path|
          requests << path
        end
      end
    end

    it "should load images by default" do
      visit("/")
      expect(requests).to match_array %w(image bgimage)
    end

    it "should not load images when disabled" do
      configure(&:skip_image_loading)
      visit("/")
      expect(requests).to eq []
    end

    let(:requests) do
      visit "/requests"
      driver.find("//p").map(&:text)
    end
  end

  describe "#set_proxy" do
    before do
      @host = "127.0.0.1"
      @user = "user"
      @pass = "secret"
      @url  = "http://example.org/"

      @server = TCPServer.new(@host, 0)
      @port = @server.addr[1]

      @proxy_requests = []
      @proxy = Thread.new(@server, @proxy_requests) do |serv, proxy_requests|
        while conn = serv.accept do
          # read request
          request = []
          until (line = conn.readline.strip).empty?
            request << line
          end

          # send response
          auth_header = request.find { |h| h =~ /Authorization:/i }
          if auth_header || request[0].split(/\s+/)[1] =~ /^\//
            html = "<html><body>D'oh!</body></html>"
            conn.write "HTTP/1.1 200 OK\r\n"
            conn.write "Content-Type:text/html\r\n"
            conn.write "Content-Length: %i\r\n" % html.size
            conn.write "\r\n"
            conn.write html
            conn.close
            proxy_requests << request if auth_header
          else
            conn.write "HTTP/1.1 407 Proxy Auth Required\r\n"
            conn.write "Proxy-Authenticate: Basic realm=\"Proxy\"\r\n"
            conn.write "\r\n"
            conn.close
            proxy_requests << request
          end
        end
      end

      configure do |config|
        config.allow_url("example.org")
        config.use_proxy host: @host, port: @port, user: @user, pass: @pass
      end

      fork_connection

      driver.visit @url
      expect(@proxy_requests.size).to eq 2
      @request = @proxy_requests[-1]
    end

    after do
      @proxy.kill
      @server.close
    end

    let(:driver) do
      driver_for_html("")
    end

    it "uses the HTTP proxy correctly" do
      expect(@request[0]).to match(/^GET\s+http:\/\/example.org\/\s+HTTP/i)
      expect(@request.find { |header| header =~ /^Host:\s+example.org$/i }).not_to be nil
    end

    it "sends correct proxy authentication" do
      auth_header = @request.find { |header|
        header =~ /^Proxy-Authorization:\s+/i }
      expect(auth_header).not_to be nil

      user, pass = Base64.decode64(auth_header.split(/\s+/)[-1]).split(":")
      expect(user).to eq @user
      expect(pass).to eq @pass
    end

    it "uses the proxy's response" do
      expect(driver.html).to include "D'oh!"
    end

    it "uses original URL" do
      expect(driver.current_url).to eq @url
    end

    it "uses URLs changed by javascript" do
      driver.execute_script %{window.history.pushState("", "", "/blah")}
      expect(driver.current_url).to eq "http://example.org/blah"
    end

    it "is possible to disable proxy again" do
      @proxy_requests.clear
      driver.browser.clear_proxy
      driver.visit "http://#{@host}:#{@port}/"
      expect(@proxy_requests.size).to eq 0
    end
  end

  def driver_url(driver, path)
    URI.parse(driver.current_url).merge(path).to_s
  end

  context "page with JavaScript errors" do
    let(:driver) do
      driver_for_app do
        get "/" do
          <<-HTML
            <!DOCTYPE html>
            <html>
            <body>
              <script type="text/javascript">
                undefinedFunc();
              </script>
            </body>
            </html>
          HTML
        end
      end
    end

    it "raises errors as an exception, when configured" do
      configure do |config|
        config.raise_javascript_errors = true
      end

      expected_error = Capybara::Webkit::JavaScriptError
      expected_message = "ReferenceError: Can't find variable: undefinedFunc"

      expect { visit("/") }.to raise_error(expected_error) do |error|
        expect(error.javascript_errors.first[:message]).to eq expected_message
      end
      expect { driver.find_css("h1") }.to raise_error(expected_error)
    end

    it "does not raise an exception when fetching the error messages" do
      configure do |config|
        config.raise_javascript_errors = true
      end

      expect { driver.error_messages }.to_not raise_error
    end

    it "does not raise errors as an exception by default" do
      expect { visit("/") }.to_not raise_error
      expect(driver.error_messages).to_not be_empty
    end
  end
end
