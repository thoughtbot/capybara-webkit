require 'spec_helper'

describe Capybara::Webkit::JsonError do
  let(:error) { described_class.new '{"class": "ClickFailed", "message": "Error clicking this element"}' }

  subject { error.exception }

  it { should be_an_instance_of Capybara::Webkit::ClickFailed }

  describe '#message' do
    subject { super().message }
    it { should == 'Error clicking this element' }
  end
end
