require 'spec_helper'
require 'capybara-webkit'

describe Capybara::Session do
  before do
    @session = Capybara::Session.new(:webkit, TestApp)
  end

  # TODO: needs to only use one Browser throughout tests
  # it_should_behave_like "session"
  # it_should_behave_like "session with javascript support"
end
