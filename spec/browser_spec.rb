require 'spec_helper'
require 'self_signed_ssl_cert'
require 'stringio'
require 'capybara/webkit/driver'
require 'socket'
require 'base64'

describe Capybara::Webkit::Browser do

  let(:server) { Capybara::Webkit::Server.new }
  let(:connection) { Capybara::Webkit::Connection.new(server: server) }
  let(:browser) { Capybara::Webkit::Browser.new(connection) }

  describe "forking", skip_on_windows: true, skip_on_jruby: true do
    it "only shuts down the server from the main process" do
      browser.reset!
      pid = fork {}
      Process.wait(pid)
      expect { browser.reset! }.not_to raise_error
    end
  end

  it "doesn't try to read an empty response" do
    connection = double("connection", puts: nil, print: nil)
    allow(connection).to receive(:gets).and_return("ok\n", "0\n")
    allow(connection).to receive(:read).and_raise(StandardError.new("tried to read empty response"))

    browser = Capybara::Webkit::Browser.new(connection)

    expect { browser.visit("/") }.not_to raise_error
  end

  describe '#command' do
    context 'non-ok response' do
      it 'raises an error of given class' do
        error_json = '{"class": "ClickFailed"}'

        expect(connection).to receive(:gets).ordered.and_return 'error'
        expect(connection).to receive(:gets).ordered.and_return error_json.bytesize
        allow(connection).to receive(:read).and_return(error_json)

        expect { browser.command 'blah', 'meh' }.to raise_error(Capybara::Webkit::ClickFailed)
      end
    end
  end

  describe "#reset!" do
    it "resets to the default state" do
      connection = double("connection", puts: nil, print: nil)
      allow(connection).to receive(:gets).and_return("ok\n", "{}\n")

      browser = Capybara::Webkit::Browser.new(connection)
      browser.set_raise_javascript_errors(true)

      expect(browser.raise_javascript_errors?).to be true

      browser.reset!

      expect(browser.raise_javascript_errors?).to be false
    end
  end
end
