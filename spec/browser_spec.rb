require 'spec_helper'
require 'capybara/driver/webkit/browser'

describe Capybara::Driver::Webkit::Browser do

  let(:browser) { Capybara::Driver::Webkit::Browser.new }

  describe '#server_port' do
    subject { browser.server_port }
    it 'returns a valid port number' do
      should be_a(Integer)
    end

    it 'returns a port in the allowed range' do
      should be_between 0x400, 0xffff
    end
  end

  context 'random port' do
    it 'chooses a new port number for a new browser instance' do
      new_browser = Capybara::Driver::Webkit::Browser.new
      new_browser.server_port.should_not == browser.server_port
    end
  end

end
