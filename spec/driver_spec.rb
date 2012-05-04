require 'spec_helper'
require 'capybara/driver/webkit'

describe Capybara::Driver::Webkit do
  subject { Capybara::Driver::Webkit.new(@app, :browser => $webkit_browser) }
  before { subject.visit("/hello/world?success=true") }
  after { subject.reset! }

  context "iframe app" do
    before(:all) do
      @app = lambda do |env|
        params = ::Rack::Utils.parse_query(env['QUERY_STRING'])
        if params["iframe"] == "true"
          # We are in an iframe request.
          p_id = "farewell"
          msg  = "goodbye"
          iframe = nil
        else
          # We are not in an iframe request and need to make an iframe!
          p_id = "greeting"
          msg  = "hello"
          iframe = "<iframe id=\"f\" src=\"/?iframe=true\"></iframe>"
        end
        body = <<-HTML
          <html>
            <head>
              <style type="text/css">
                #display_none { display: none }
              </style>
            </head>
            <body>
              #{iframe}
              <script type="text/javascript">
                document.write("<p id='#{p_id}'>#{msg}</p>");
              </script>
            </body>
          </html>
        HTML
        [200,
          { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
          [body]]
      end
    end

    it "finds frames by index" do
      subject.within_frame(0) do
        subject.find("//*[contains(., 'goodbye')]").should_not be_empty
      end
    end

    it "finds frames by id" do
      subject.within_frame("f") do
        subject.find("//*[contains(., 'goodbye')]").should_not be_empty
      end
    end

    it "raises error for missing frame by index" do
      expect { subject.within_frame(1) { } }.
        to raise_error(Capybara::Driver::Webkit::WebkitInvalidResponseError)
    end

    it "raise_error for missing frame by id" do
      expect { subject.within_frame("foo") { } }.
        to raise_error(Capybara::Driver::Webkit::WebkitInvalidResponseError)
    end

    it "returns an attribute's value" do
      subject.within_frame("f") do
        subject.find("//p").first["id"].should == "farewell"
      end
    end

    it "returns a node's text" do
      subject.within_frame("f") do
        subject.find("//p").first.text.should == "goodbye"
      end
    end

    it "returns the current URL" do
      subject.within_frame("f") do
        port = subject.instance_variable_get("@rack_server").port
        subject.current_url.should == "http://127.0.0.1:#{port}/?iframe=true"
      end
    end

    it "returns the source code for the page" do
      subject.within_frame("f") do
        subject.source.should =~ %r{<html>.*farewell.*}m
      end
    end

    it "evaluates Javascript" do
      subject.within_frame("f") do
        result = subject.evaluate_script(%<document.getElementById('farewell').innerText>)
        result.should == "goodbye"
      end
    end

    it "executes Javascript" do
      subject.within_frame("f") do
        subject.execute_script(%<document.getElementById('farewell').innerHTML = 'yo'>)
        subject.find("//p[contains(., 'yo')]").should_not be_empty
      end
    end
  end

  context "redirect app" do
    before(:all) do
      @app = lambda do |env|
        if env['PATH_INFO'] == '/target'
          content_type = "<p>#{env['CONTENT_TYPE']}</p>"
          [200, {"Content-Type" => "text/html", "Content-Length" => content_type.length.to_s}, [content_type]]
        elsif env['PATH_INFO'] == '/form'
          body = <<-HTML
            <html>
              <body>
                <form action="/redirect" method="POST" enctype="multipart/form-data">
                  <input name="submit" type="submit" />
                </form>
              </body>
            </html>
          HTML
          [200, {"Content-Type" => "text/html", "Content-Length" => body.length.to_s}, [body]]
        else
          [301, {"Location" => "/target"}, [""]]
        end
      end
    end

    it "should redirect without content type" do
      subject.visit("/form")
      subject.find("//input").first.click
      subject.find("//p").first.text.should == ""
    end

    it "returns the current URL when changed by pushState after a redirect" do
      subject.visit("/redirect-me")
      port = subject.instance_variable_get("@rack_server").port
      subject.execute_script("window.history.pushState({}, '', '/pushed-after-redirect')")
      subject.current_url.should == "http://127.0.0.1:#{port}/pushed-after-redirect"
    end

    it "returns the current URL when changed by replaceState after a redirect" do
      subject.visit("/redirect-me")
      port = subject.instance_variable_get("@rack_server").port
      subject.execute_script("window.history.replaceState({}, '', '/replaced-after-redirect')")
      subject.current_url.should == "http://127.0.0.1:#{port}/replaced-after-redirect"
    end
  end

  context "css app" do
    before(:all) do
      body = "css"
      @app = lambda do |env|
        [200, {"Content-Type" => "text/css", "Content-Length" => body.length.to_s}, [body]]
      end
      subject.visit("/")
    end

    it "renders unsupported content types gracefully" do
      subject.body.should =~ /css/
    end

    it "sets the response headers with respect to the unsupported request" do
      subject.response_headers["Content-Type"].should == "text/css"
    end
  end

  context "hello app" do
    before(:all) do
      @app = lambda do |env|
        body = <<-HTML
          <html>
            <head>
              <style type="text/css">
                #display_none { display: none }
              </style>
            </head>
            <body>
              <div class='normalize'>Spaces&nbsp;not&nbsp;normalized&nbsp;</div>
              <div id="display_none">
                <div id="invisible">Can't see me</div>
              </div>
              <input type="text" disabled="disabled"/>
              <input id="checktest" type="checkbox" checked="checked"/>
              <script type="text/javascript">
                document.write("<p id='greeting'>he" + "llo</p>");
              </script>
            </body>
          </html>
        HTML
        [200,
          { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
          [body]]
      end
    end

    it "handles anchor tags" do
      subject.visit("#test")
      subject.find("//*[contains(., 'hello')]").should_not be_empty
      subject.visit("#test")
      subject.find("//*[contains(., 'hello')]").should_not be_empty
    end

    it "finds content after loading a URL" do
      subject.find("//*[contains(., 'hello')]").should_not be_empty
    end

    it "has an empty page after reseting" do
      subject.reset!
      subject.find("//*[contains(., 'hello')]").should be_empty
    end

    it "has a location of 'about:blank' after reseting" do
      subject.reset!
      subject.current_url.should == "about:blank"
    end

    it "raises an error for an invalid xpath query" do
      expect { subject.find("totally invalid salad") }.
        to raise_error(Capybara::Driver::Webkit::WebkitInvalidResponseError, /xpath/i)
    end

    it "returns an attribute's value" do
      subject.find("//p").first["id"].should == "greeting"
    end

    it "parses xpath with quotes" do
      subject.find('//*[contains(., "hello")]').should_not be_empty
    end

    it "returns a node's text" do
      subject.find("//p").first.text.should == "hello"
    end

    it "normalizes a node's text" do
      subject.find("//div[contains(@class, 'normalize')]").first.text.should == "Spaces not normalized"
    end

    it "returns the current URL" do
      port = subject.instance_variable_get("@rack_server").port
      subject.current_url.should == "http://127.0.0.1:#{port}/hello/world?success=true"
    end

    it "returns the current URL when changed by pushState" do
      port = subject.instance_variable_get("@rack_server").port
      subject.execute_script("window.history.pushState({}, '', '/pushed')")
      subject.current_url.should == "http://127.0.0.1:#{port}/pushed"
    end

    it "returns the current URL when changed by replaceState" do
      port = subject.instance_variable_get("@rack_server").port
      subject.execute_script("window.history.replaceState({}, '', '/replaced')")
      subject.current_url.should == "http://127.0.0.1:#{port}/replaced"
    end

    it "does not double-encode URLs" do
      subject.visit("/hello/world?success=%25true")
      subject.current_url.should =~ /success=\%25true/
    end

    it "visits a page with an anchor" do
      subject.visit("/hello#display_none")
      subject.current_url.should =~ /hello#display_none/
    end

    it "returns the source code for the page" do
      subject.source.should =~ %r{<html>.*greeting.*}m
    end

    it "evaluates Javascript and returns a string" do
      result = subject.evaluate_script(%<document.getElementById('greeting').innerText>)
      result.should == "hello"
    end

    it "evaluates Javascript and returns an array" do
      result = subject.evaluate_script(%<["hello", "world"]>)
      result.should == %w(hello world)
    end

    it "evaluates Javascript and returns an int" do
      result = subject.evaluate_script(%<123>)
      result.should == 123
    end

    it "evaluates Javascript and returns a float" do
      result = subject.evaluate_script(%<1.5>)
      result.should == 1.5
    end

    it "evaluates Javascript and returns null" do
      result = subject.evaluate_script(%<(function () {})()>)
      result.should == nil
    end

    it "evaluates Javascript and returns an object" do
      result = subject.evaluate_script(%<({ 'one' : 1 })>)
      result.should == { 'one' => 1 }
    end

    it "evaluates Javascript and returns true" do
      result = subject.evaluate_script(%<true>)
      result.should === true
    end

    it "evaluates Javascript and returns false" do
      result = subject.evaluate_script(%<false>)
      result.should === false
    end

    it "evaluates Javascript and returns an escaped string" do
      result = subject.evaluate_script(%<'"'>)
      result.should === "\""
    end

    it "evaluates Javascript with multiple lines" do
      result = subject.evaluate_script("[1,\n2]")
      result.should == [1, 2]
    end

    it "executes Javascript" do
      subject.execute_script(%<document.getElementById('greeting').innerHTML = 'yo'>)
      subject.find("//p[contains(., 'yo')]").should_not be_empty
    end

    it "raises an error for failing Javascript" do
      expect { subject.execute_script(%<invalid salad>) }.
        to raise_error(Capybara::Driver::Webkit::WebkitInvalidResponseError)
    end

    it "doesn't raise an error for Javascript that doesn't return anything" do
      lambda { subject.execute_script(%<(function () { "returns nothing" })()>) }.
        should_not raise_error
    end

    it "returns a node's tag name" do
      subject.find("//p").first.tag_name.should == "p"
    end

    it "reads disabled property" do
      subject.find("//input").first.should be_disabled
    end

    it "reads checked property" do
      subject.find("//input[@id='checktest']").first.should be_checked
    end

    it "finds visible elements" do
      subject.find("//p").first.should be_visible
      subject.find("//*[@id='invisible']").first.should_not be_visible
    end
  end

  context "console messages app" do

    before(:all) do
      @app = lambda do |env|
        body = <<-HTML
          <html>
            <head>
            </head>
            <body>
              <script type="text/javascript">
                console.log("hello");
                console.log("hello again");
                oops
              </script>
            </body>
          </html>
        HTML
        [200,
          { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
          [body]]
      end
    end

    it "collects messages logged to the console" do
      subject.console_messages.first.should include :source, :message => "hello", :line_number => 6
      subject.console_messages.length.should eq 3
    end

    it "logs errors to the console" do
      subject.error_messages.length.should eq 1
    end

  end

  context "form app" do
    before(:all) do
      @app = lambda do |env|
        body = <<-HTML
          <html><body>
            <form action="/" method="GET">
              <input type="text" name="foo" value="bar"/>
              <input type="text" name="maxlength_foo" value="bar" maxlength="10"/>
              <input type="text" id="disabled_input" disabled="disabled"/>
              <input type="checkbox" name="checkedbox" value="1" checked="checked"/>
              <input type="checkbox" name="uncheckedbox" value="2"/>
              <select name="animal">
                <option id="select-option-monkey">Monkey</option>
                <option id="select-option-capybara" selected="selected">Capybara</option>
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
              <textarea id="only-textarea">what a wonderful area for text</textarea>
              <input type="radio" id="only-radio" value="1"/>
              <button type="reset">Reset Form</button>
            </form>
          </body></html>
        HTML
        [200,
          { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
          [body]]
      end
    end

    it "returns a textarea's value" do
      subject.find("//textarea").first.value.should == "what a wonderful area for text"
    end

    it "returns a text input's value" do
      subject.find("//input").first.value.should == "bar"
    end

    it "returns a select's value" do
      subject.find("//select").first.value.should == "Capybara"
    end

    it "sets an input's value" do
      input = subject.find("//input").first
      input.set("newvalue")
      input.value.should == "newvalue"
    end

    it "sets an input's value greater than the max length" do
      input = subject.find("//input[@name='maxlength_foo']").first
      input.set("allegories (poems)")
      input.value.should == "allegories"
    end

    it "sets an input's value equal to the max length" do
      input = subject.find("//input[@name='maxlength_foo']").first
      input.set("allegories")
      input.value.should == "allegories"
    end

    it "sets an input's value less than the max length" do
      input = subject.find("//input[@name='maxlength_foo']").first
      input.set("poems")
      input.value.should == "poems"
    end

    it "sets an input's nil value" do
      input = subject.find("//input").first
      input.set(nil)
      input.value.should == ""
    end

    it "sets a select's value" do
      select = subject.find("//select").first
      select.set("Monkey")
      select.value.should == "Monkey"
    end

    it "sets a textarea's value" do
      textarea = subject.find("//textarea").first
      textarea.set("newvalue")
      textarea.value.should == "newvalue"
    end

    let(:monkey_option)   { subject.find("//option[@id='select-option-monkey']").first }
    let(:capybara_option) { subject.find("//option[@id='select-option-capybara']").first }
    let(:animal_select)   { subject.find("//select[@name='animal']").first }
    let(:apple_option)    { subject.find("//option[@id='topping-apple']").first }
    let(:banana_option)   { subject.find("//option[@id='topping-banana']").first }
    let(:cherry_option)   { subject.find("//option[@id='topping-cherry']").first }
    let(:toppings_select) { subject.find("//select[@name='toppings']").first }
    let(:reset_button)    { subject.find("//button[@type='reset']").first }

    context "a select element's selection has been changed" do
      before do
        animal_select.value.should == "Capybara"
        monkey_option.select_option
      end

      it "returns the new selection" do
        animal_select.value.should == "Monkey"
      end

      it "does not modify the selected attribute of a new selection" do
        monkey_option['selected'].should be_empty
      end

      it "returns the old value when a reset button is clicked" do
        reset_button.click

        animal_select.value.should == "Capybara"
      end
    end

    context "a multi-select element's option has been unselected" do
      before do
        toppings_select.value.should include("Apple", "Banana", "Cherry")

        apple_option.unselect_option
      end

      it "does not return the deselected option" do
        toppings_select.value.should_not include("Apple")
      end

      it "returns the deselected option when a reset button is clicked" do
        reset_button.click

        toppings_select.value.should include("Apple", "Banana", "Cherry")
      end
    end

    it "reselects an option in a multi-select" do
      apple_option.unselect_option
      banana_option.unselect_option
      cherry_option.unselect_option

      toppings_select.value.should == []

      apple_option.select_option
      banana_option.select_option
      cherry_option.select_option

      toppings_select.value.should include("Apple", "Banana", "Cherry")
    end

    let(:checked_box) { subject.find("//input[@name='checkedbox']").first }
    let(:unchecked_box) { subject.find("//input[@name='uncheckedbox']").first }

    it "knows a checked box is checked" do
      checked_box['checked'].should be_true
    end

    it "knows a checked box is checked using checked?" do
      checked_box.should be_checked
    end

    it "knows an unchecked box is unchecked" do
      unchecked_box['checked'].should_not be_true
    end

    it "knows an unchecked box is unchecked using checked?" do
      unchecked_box.should_not be_checked
    end

    it "checks an unchecked box" do
      unchecked_box.set(true)
      unchecked_box.should be_checked
    end

    it "unchecks a checked box" do
      checked_box.set(false)
      checked_box.should_not be_checked
    end

    it "leaves a checked box checked" do
      checked_box.set(true)
      checked_box.should be_checked
    end

    it "leaves an unchecked box unchecked" do
      unchecked_box.set(false)
      unchecked_box.should_not be_checked
    end

    let(:enabled_input)  { subject.find("//input[@name='foo']").first }
    let(:disabled_input) { subject.find("//input[@id='disabled_input']").first }

    it "knows a disabled input is disabled" do
      disabled_input['disabled'].should be_true
    end

    it "knows a not disabled input is not disabled" do
      enabled_input['disabled'].should_not be_true
    end
  end

  context "dom events" do
    before(:all) do
      @app = lambda do |env|
        body = <<-HTML

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
              }
            </script>
          </body></html>
        HTML
        [200,
          { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
          [body]]
      end
    end

    it "triggers mouse events" do
      subject.find("//a").first.click
      subject.find("//li").map(&:text).should == %w(mousedown mouseup click)
    end
  end

  context "form events app" do
    before(:all) do
      @app = lambda do |env|
        body = <<-HTML
          <html><body>
            <form action="/" method="GET">
              <input class="watch" type="email"/>
              <input class="watch" type="number"/>
              <input class="watch" type="password"/>
              <input class="watch" type="search"/>
              <input class="watch" type="tel"/>
              <input class="watch" type="text"/>
              <input class="watch" type="url"/>
              <textarea class="watch"></textarea>
              <input class="watch" type="checkbox"/>
              <input class="watch" type="radio"/>
            </form>
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
                element.addEventListener("focus", recordEvent);
                element.addEventListener("keydown", recordEvent);
                element.addEventListener("keypress", recordEvent);
                element.addEventListener("keyup", recordEvent);
                element.addEventListener("input", recordEvent);
                element.addEventListener("change", recordEvent);
                element.addEventListener("blur", recordEvent);
                element.addEventListener("mousedown", recordEvent);
                element.addEventListener("mouseup", recordEvent);
                element.addEventListener("click", recordEvent);
              }
            </script>
          </body></html>
        HTML
        [200,
          { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
          [body]]
      end
    end

    let(:newtext) { 'newvalue' }

    let(:keyevents) do
      (%w{focus} +
       newtext.length.times.collect { %w{keydown keypress keyup input} } +
       %w{change blur}).flatten
    end

    %w(email number password search tel text url).each do | field_type |
      it "triggers text input events on inputs of type #{field_type}" do
        subject.find("//input[@type='#{field_type}']").first.set(newtext)
        subject.find("//li").map(&:text).should == keyevents
      end
    end

    it "triggers textarea input events" do
      subject.find("//textarea").first.set(newtext)
      subject.find("//li").map(&:text).should == keyevents
    end

    it "triggers radio input events" do
      subject.find("//input[@type='radio']").first.set(true)
      subject.find("//li").map(&:text).should == %w(mousedown mouseup change click)
    end

    it "triggers checkbox events" do
      subject.find("//input[@type='checkbox']").first.set(true)
      subject.find("//li").map(&:text).should == %w(mousedown mouseup change click)
    end
  end

  context "mouse app" do
    before(:all) do
      @app =lambda do |env|
        body = <<-HTML
          <html><body>
            <div id="change">Change me</div>
            <div id="mouseup">Push me</div>
            <div id="mousedown">Release me</div>
            <form action="/" method="GET">
              <select id="change_select" name="change_select">
                <option value="1" id="option-1" selected="selected">one</option>
                <option value="2" id="option-2">two</option>
              </select>
            </form>
            <script type="text/javascript">
              document.getElementById("change_select").
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
        [200,
          { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
          [body]]
      end
    end

    it "clicks an element" do
      subject.find("//a").first.click
      subject.current_url =~ %r{/next$}
    end

    it "fires a mouse event" do
      subject.find("//*[@id='mouseup']").first.trigger("mouseup")
      subject.find("//*[@class='triggered']").should_not be_empty
    end

    it "fires a non-mouse event" do
      subject.find("//*[@id='change']").first.trigger("change")
      subject.find("//*[@class='triggered']").should_not be_empty
    end

    it "fires a change on select" do
      select = subject.find("//select").first
      select.value.should == "1"
      option = subject.find("//option[@id='option-2']").first
      option.select_option
      select.value.should == "2"
      subject.find("//select[@class='triggered']").should_not be_empty
    end

    it "fires drag events" do
      draggable = subject.find("//*[@id='mousedown']").first
      container = subject.find("//*[@id='mouseup']").first

      draggable.drag_to(container)

      subject.find("//*[@class='triggered']").size.should == 1
    end
  end

  context "nesting app" do
    before(:all) do
      @app = lambda do |env|
        body = <<-HTML
          <html><body>
            <div id="parent">
              <div class="find">Expected</div>
            </div>
            <div class="find">Unexpected</div>
          </body></html>
        HTML
        [200,
          { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
          [body]]
      end
    end

    it "evaluates nested xpath expressions" do
      parent = subject.find("//*[@id='parent']").first
      parent.find("./*[@class='find']").map(&:text).should == %w(Expected)
    end
  end

  context "slow app" do
    before(:all) do
      @result = ""
      @app = lambda do |env|
        if env["PATH_INFO"] == "/result"
          sleep(0.5)
          @result << "finished"
        end
        body = %{<html><body><a href="/result">Go</a></body></html>}
        [200,
          { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
          [body]]
      end
    end

    it "waits for a request to load" do
      subject.find("//a").first.click
      @result.should == "finished"
    end
  end

  context "error app" do
    before(:all) do
      @app = lambda do |env|
        if env['PATH_INFO'] == "/error"
          [404, {}, []]
        else
          body = <<-HTML
            <html><body>
              <form action="/error"><input type="submit"/></form>
            </body></html>
          HTML
          [200,
            { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
            [body]]
        end
      end
    end

    it "raises a webkit error for the requested url" do
      expect {
        subject.find("//input").first.click
        wait_for_error_to_complete
        subject.find("//body")
      }.
        to raise_error(Capybara::Driver::Webkit::WebkitInvalidResponseError, %r{/error})
    end

    def wait_for_error_to_complete
      sleep(0.5)
    end
  end

  context "slow error app" do
    before(:all) do
      @app = lambda do |env|
        if env['PATH_INFO'] == "/error"
          body = "error"
          sleep(1)
          [304, {}, []]
        else
          body = <<-HTML
            <html><body>
              <form action="/error"><input type="submit"/></form>
              <p>hello</p>
            </body></html>
          HTML
          [200,
            { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
            [body]]
        end
      end
    end

    it "raises a webkit error and then continues" do
      subject.find("//input").first.click
      expect { subject.find("//p") }.to raise_error(Capybara::Driver::Webkit::WebkitInvalidResponseError)
      subject.visit("/")
      subject.find("//p").first.text.should == "hello"
    end
  end

  context "popup app" do
    before(:all) do
      @app = lambda do |env|
        body = <<-HTML
          <html><body>
            <script type="text/javascript">
              alert("alert");
              confirm("confirm");
              prompt("prompt");
            </script>
            <p>success</p>
          </body></html>
        HTML
        sleep(0.5)
        [200,
          { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
          [body]]
      end
    end

    it "doesn't crash from alerts" do
      subject.find("//p").first.text.should == "success"
    end
  end

  context "custom header" do
    before(:all) do
      @app = lambda do |env|
        body = <<-HTML
          <html><body>
            <p id="user-agent">#{env['HTTP_USER_AGENT']}</p>
            <p id="x-capybara-webkit-header">#{env['HTTP_X_CAPYBARA_WEBKIT_HEADER']}</p>
            <p id="accept">#{env['HTTP_ACCEPT']}</p>
            <a href="/">/</a>
          </body></html>
        HTML
        [200,
          { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
          [body]]
      end
    end

    before do
      subject.header('user-agent', 'capybara-webkit/custom-user-agent')
      subject.header('x-capybara-webkit-header', 'x-capybara-webkit-header')
      subject.header('accept', 'text/html')
      subject.visit('/')
    end

    it "can set user_agent" do
      subject.find('id("user-agent")').first.text.should == 'capybara-webkit/custom-user-agent'
      subject.evaluate_script('navigator.userAgent').should == 'capybara-webkit/custom-user-agent'
    end

    it "keep user_agent in next page" do
      subject.find("//a").first.click
      subject.find('id("user-agent")').first.text.should == 'capybara-webkit/custom-user-agent'
      subject.evaluate_script('navigator.userAgent').should == 'capybara-webkit/custom-user-agent'
    end

    it "can set custom header" do
      subject.find('id("x-capybara-webkit-header")').first.text.should == 'x-capybara-webkit-header'
    end

    it "can set Accept header" do
      subject.find('id("accept")').first.text.should == 'text/html'
    end

    it "can reset all custom header" do
      subject.reset!
      subject.visit('/')
      subject.find('id("user-agent")').first.text.should_not == 'capybara-webkit/custom-user-agent'
      subject.evaluate_script('navigator.userAgent').should_not == 'capybara-webkit/custom-user-agent'
      subject.find('id("x-capybara-webkit-header")').first.text.should be_empty
      subject.find('id("accept")').first.text.should_not == 'text/html'
    end
  end

  context "no response app" do
    before(:all) do
      @app = lambda do |env|
        body = <<-HTML
          <html><body>
            <form action="/error"><input type="submit"/></form>
          </body></html>
        HTML
        [200,
          { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
          [body]]
      end
    end

    it "raises a webkit error for the requested url" do
      make_the_server_go_away
      expect {
        subject.find("//body")
      }.
       to raise_error(Capybara::Driver::Webkit::WebkitNoResponseError, %r{response})
      make_the_server_come_back
    end

    def make_the_server_come_back
      subject.browser.instance_variable_get(:@connection).unstub!(:gets)
      subject.browser.instance_variable_get(:@connection).unstub!(:puts)
      subject.browser.instance_variable_get(:@connection).unstub!(:print)
    end

    def make_the_server_go_away
      subject.browser.instance_variable_get(:@connection).stub!(:gets).and_return(nil)
      subject.browser.instance_variable_get(:@connection).stub!(:puts)
      subject.browser.instance_variable_get(:@connection).stub!(:print)
    end
  end

  context "custom font app" do
    before(:all) do
      @app = lambda do |env|
        body = <<-HTML
          <html>
            <head>
              <style type="text/css">
                p { font-family: "Verdana"; }
              </style>
            </head>
            <body>
              <p id="text">Hello</p>
            </body>
          </html>
        HTML
        [200,
          { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
          [body]]
      end
    end

    it "ignores custom fonts" do
      font_family = subject.evaluate_script(<<-SCRIPT)
        var element = document.getElementById("text");
        element.ownerDocument.defaultView.getComputedStyle(element, null).getPropertyValue("font-family");
      SCRIPT
      font_family.should == "Arial"
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
      subject.find('id("cookie")').first.text
    end

    it "remembers the cookie on second visit" do
      echoed_cookie.should == ""
      subject.visit "/"
      echoed_cookie.should == "abc"
    end

    it "uses a custom cookie" do
      subject.browser.set_cookie @cookie
      subject.visit "/"
      echoed_cookie.should == "abc"
    end

    it "clears cookies" do
      subject.browser.clear_cookies
      subject.visit "/"
      echoed_cookie.should == ""
    end

    it "allows enumeration of cookies" do
      cookies = subject.browser.get_cookies

      cookies.size.should == 1

      cookie = Hash[cookies[0].split(/\s*;\s*/).map { |x| x.split("=", 2) }]
      cookie["cookie"].should == "abc"
      cookie["domain"].should include "127.0.0.1"
      cookie["path"].should == "/"
    end

    it "allows reading access to cookies using a nice syntax" do
      subject.cookies["cookie"].should == "abc"
    end
  end

  context "with socket debugger" do
    let(:socket_debugger_class){ Capybara::Driver::Webkit::SocketDebugger }
    let(:browser_with_debugger){
      connection = Capybara::Driver::Webkit::Connection.new(:socket_class => socket_debugger_class)
      Capybara::Driver::Webkit::Browser.new(connection)
    }
    let(:driver_with_debugger){ Capybara::Driver::Webkit.new(@app, :browser => browser_with_debugger) }

    before(:all) do
      @app = lambda do |env|
        body = <<-HTML
          <html><body>
            <div id="parent">
              <div class="find">Expected</div>
            </div>
            <div class="find">Unexpected</div>
          </body></html>
        HTML
        [200,
          { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
          [body]]
      end
    end

    it "prints out sent content" do
      socket_debugger_class.any_instance.stub(:received){|content| content }
      sent_content = ['Find', 1, 17, "//*[@id='parent']"]
      socket_debugger_class.any_instance.should_receive(:sent).exactly(sent_content.size).times
      driver_with_debugger.find("//*[@id='parent']")
    end

    it "prints out received content" do
      socket_debugger_class.any_instance.stub(:sent)
      socket_debugger_class.any_instance.should_receive(:received).at_least(:once).and_return("ok")
      driver_with_debugger.find("//*[@id='parent']")
    end
  end

  context "remove node app" do
    before(:all) do
      @app = lambda do |env|
        body = <<-HTML
          <html>
            <div id="parent">
              <p id="removeMe">Hello</p>
            </div>
          </html>
        HTML
        [200,
          { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
          [body]]
      end
    end

    before { set_automatic_reload false }
    after { set_automatic_reload true }

    def set_automatic_reload(value)
      if Capybara.respond_to?(:automatic_reload)
        Capybara.automatic_reload = value
      end
    end

    it "allows removed nodes when reloading is disabled" do
      node = subject.find("//p[@id='removeMe']").first
      subject.evaluate_script("document.getElementById('parent').innerHTML = 'Magic'")
      node.text.should == 'Hello'
    end
  end

  context "app with a lot of HTML tags" do
    before(:all) do
      @app = lambda do |env|
        body = <<-HTML
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
        [200,
          { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
          [body]]
      end
    end

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
        nodes = subject.find(xpath)
        nodes.size.should == 1
        nodes[0].path.should == path
      end
    end
  end

  context "css overflow app" do
    before(:all) do
      @app = lambda do |env|
        body = <<-HTML
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
        [200,
          { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
          [body]]
      end
    end

    it "handles overflow hidden" do
      subject.find("//div[@id='overflow']").first.text.should == "Overflow"
    end
  end

  context "javascript redirect app" do
    before(:all) do
      @app = lambda do |env|
        if env['PATH_INFO'] == '/redirect'
          body = <<-HTML
            <html>
              <script type="text/javascript">
                window.location = "/next";
              </script>
            </html>
          HTML
        else
          body = "<html><p>finished</p></html>"
        end
        [200,
          { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
          [body]]
      end
    end

    it "loads a page without error" do
      10.times do
        subject.visit("/redirect")
        subject.find("//p").first.text.should == "finished"
      end
    end
  end

  context "localStorage works" do
    before(:all) do
      @app = lambda do |env|
        body = <<-HTML
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
        [200,
          { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
          [body]]
      end
    end

    it "displays the message on subsequent page loads" do
      subject.find("//span[contains(.,'localStorage is enabled')]").should be_empty
      subject.visit "/"
      subject.find("//span[contains(.,'localStorage is enabled')]").should_not be_empty
    end
  end

  context "app with a lot of HTML tags" do
    before(:all) do
      @app = lambda do |env|
        body = <<-HTML
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
        [200,
          { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
          [body]]
      end
    end

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
        nodes = subject.find(xpath)
        nodes.size.should == 1
        nodes[0].path.should == path
      end
    end
  end

  context "form app with server-side handler" do
    before(:all) do
      @app = lambda do |env|
        if env["REQUEST_METHOD"] == "POST"
          body = "<html><body><p>Congrats!</p></body></html>"
        else
          body = <<-HTML
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
        [200,
          { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
          [body]]
      end
    end

    it "submits a form without clicking" do
      subject.find("//form")[0].submit
      subject.body.should include "Congrats"
    end
  end

  def key_app_body(event)
    body = <<-HTML
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
    body
  end

  def charCode_for(character)
    subject.find("//input")[0].set(character)
    subject.find("//div[@id='charcode_value']")[0].text
  end

  def keyCode_for(character)
    subject.find("//input")[0].set(character)
    subject.find("//div[@id='keycode_value']")[0].text
  end

  def which_for(character)
    subject.find("//input")[0].set(character)
    subject.find("//div[@id='which_value']")[0].text
  end

  context "keypress app" do
    before(:all) do
      @app = lambda do |env|
        body = key_app_body("keypress")
        [200, { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s }, [body]]
      end
    end

    it "returns the charCode for the keypressed" do
      charCode_for("a").should == "97"
      charCode_for("A").should == "65"
      charCode_for("\r").should == "13"
      charCode_for(",").should == "44"
      charCode_for("<").should == "60"
      charCode_for("0").should == "48"
    end

    it "returns the keyCode for the keypressed" do
      keyCode_for("a").should == "97"
      keyCode_for("A").should == "65"
      keyCode_for("\r").should == "13"
      keyCode_for(",").should == "44"
      keyCode_for("<").should == "60"
      keyCode_for("0").should == "48"
    end

    it "returns the which for the keypressed" do
      which_for("a").should == "97"
      which_for("A").should == "65"
      which_for("\r").should == "13"
      which_for(",").should == "44"
      which_for("<").should == "60"
      which_for("0").should == "48"
    end
  end

  shared_examples "a keyupdown app" do
    it "returns a 0 charCode for the event" do
      charCode_for("a").should == "0"
      charCode_for("A").should == "0"
      charCode_for("\r").should == "0"
      charCode_for(",").should == "0"
      charCode_for("<").should == "0"
      charCode_for("0").should == "0"
    end

    it "returns the keyCode for the event" do
      keyCode_for("a").should == "65"
      keyCode_for("A").should == "65"
      keyCode_for("\r").should == "13"
      keyCode_for(",").should == "188"
      keyCode_for("<").should == "188"
      keyCode_for("0").should == "48"
    end

    it "returns the which for the event" do
      which_for("a").should == "65"
      which_for("A").should == "65"
      which_for("\r").should == "13"
      which_for(",").should == "188"
      which_for("<").should == "188"
      which_for("0").should == "48"
    end
  end

  context "keydown app" do
    before(:all) do
      @app = lambda do |env|
        body = key_app_body("keydown")
        [200, { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s }, [body]]
      end
    end
    it_behaves_like "a keyupdown app"
  end

  context "keyup app" do
    before(:all) do
      @app = lambda do |env|
        body = key_app_body("keyup")
        [200, { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s }, [body]]
      end
    end

    it_behaves_like "a keyupdown app"
  end

  context "null byte app" do
    before(:all) do
      @app = lambda do |env|
        body = "Hello\0World"
        [200,
          { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
          [body]]
      end
    end

    it "should include all the bytes in the source" do
      subject.source.should == "Hello\0World"
    end
  end
end
