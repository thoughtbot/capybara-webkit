require 'spec_helper'
require 'capybara/driver/webkit'

describe Capybara::Driver::Webkit do
  before(:all) { @@browser = Capybara::Driver::Webkit::Browser.new }
  subject { Capybara::Driver::Webkit.new(app, :browser => @@browser) }
  before { subject.visit("/hello/world?success=true") }
  after { subject.reset! }

  context "hello app" do
    let(:app) do
      lambda do |env|
        body = <<-HTML
          <html><body>
            <div style="display: none">
              <div id="invisible">Can't see me</div>
            </div>
            <script type="text/javascript">
              document.write("<p id='greeting'>he" + "llo</p>");
            </script>
          </body></html>
        HTML
        [200,
          { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
          [body]]
      end
    end

    it "finds content after loading a URL" do
      subject.find("//*[contains(., 'hello')]").should_not be_empty
    end

    it "has an empty page after reseting" do
      subject.reset!
      subject.find("//*[contains(., 'hello')]").should be_empty
    end

    it "raises an error for an invalid xpath query" do
      expect { subject.find("totally invalid salad") }.
        to raise_error(Capybara::Driver::Webkit::WebkitError, /xpath/i)
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

    it "returns the current URL" do
      port = subject.instance_variable_get("@rack_server").port
      subject.current_url.should == "http://127.0.0.1:#{port}/hello/world?success=true"
    end

    it "returns the source code for the page" do
      subject.source.should =~ %r{<html>.*greeting.*}m
    end

    it "aliases body as source" do
      subject.body.should == subject.source
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
        to raise_error(Capybara::Driver::Webkit::WebkitError)
    end

    it "returns a node's tag name" do
      subject.find("//p").first.tag_name.should == "p"
    end

    it "finds visible elements" do
      subject.find("//p").first.should be_visible
      subject.find("//*[@id='invisible']").first.should_not be_visible
    end
  end

  context "form app" do
    let(:app) do
      lambda do |env|
        body = <<-HTML
          <html><body>
            <form action="/" method="GET">
              <input type="text" name="foo" value="bar"/>
              <select name="animal">
                <option>Monkey</option>
                <option selected="selected">Capybara</option>
              </select>
              <textarea id="only-textarea">what a wonderful area for text</textarea>
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
  end

  context "mouse app" do
    let(:app) do
      lambda do |env|
        body = <<-HTML
          <html><body>
            <div id="change">Change me</div>
            <div id="mouseup">Push me</div>
            <div id="mousedown">Release me</div>
            <script type="text/javascript">
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

    it "fires drag events" do
      draggable = subject.find("//*[@id='mousedown']").first
      container = subject.find("//*[@id='mouseup']").first

      draggable.drag_to(container)

      subject.find("//*[@class='triggered']").size.should == 2
    end
  end

  context "nesting app" do
    let(:app) do
      lambda do |env|
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
end
