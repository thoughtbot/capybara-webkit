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
  end
end
