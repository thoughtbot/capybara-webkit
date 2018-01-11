# -*- encoding: UTF-8 -*-

require "spec_helper"
require "capybara/webkit/driver"
require "base64"
require "self_signed_ssl_cert"

describe Capybara::Webkit::Node do
  include AppRunner

  def visit(path, driver = self.driver)
    driver.visit(url(path))
  end

  def url(path)
    "#{AppRunner.app_host}#{path}"
  end

  context "html app" do
    let(:driver) do
      driver_for_html(<<-HTML)
        <html>
          <head>
            <title>Hello HTML</title>
          </head>
          <body>
            <form action="/" method="GET">
              <input type="text" name="foo" value="bar"/>
              <input type="checkbox" name="checkedbox" value="1" checked="checked"/>
              <input type="checkbox" name="uncheckedbox" value="2"/>
              <input type="checkbox" name="falsecheckedbox" value="3" checked="false"/>
              <input type="text" name="styled" style="font-size: 150%;"/>
            </form>

            <div id="visibility_wrapper" style="visibility: hidden">
              <div id="hidden">Hidden</div>
              <div id="visible" style="visibility: visible">Visibile</div>
              <div style="visibility: visible">
                <div id="nested_visible">Nested Visibile</div>
              </div>
            </div>

            <div id="display_none" style="display: none">
              <div id="not_displayed" style="visibility: visible; display: block;">Should not be displayed</div>
            </div>
          </body>
        </html>
      HTML
    end

    before { visit("/") }

    context "Node#[]" do
      it "gets boolean properties" do
        box1 = driver.find_css('input[name="checkedbox"]').first
        box2 = driver.find_css('input[name="uncheckedbox"]').first
        box3 = driver.find_css('input[name="falsecheckedbox"]').first
        expect(box1["checked"]).to eq true
        expect(box2["checked"]).to eq false
        expect(box3["checked"]).to eq true
        box1.set(false)
        expect(box1["checked"]).to eq false
      end

      it "prefers property over attribute" do
        input = driver.find_css('input[name="foo"]').first
        expect(input["value"]).to eq "bar"
        input.set("new value")
        expect(input["value"]).to eq "new value"
      end

      it "returns attribute when property is an object" do
        input = driver.find_css('input[name="styled"]').first
        expect(input["style"]).to eq "font-size: 150%;"
      end
    end

    context "Node#visible" do
      it "correctly analyzes visibility CSS" do
        expect(driver.find_css('#hidden').first.visible?).to be false
        expect(driver.find_css('#visible').first.visible?).to be true
        expect(driver.find_css('#nested_visible').first.visible?).to be true
      end

      it "correctly analyzes display: none CSS" do
        expect(driver.find_css('#not_displayed').first.visible?).to be false
      end
    end
  end
end
