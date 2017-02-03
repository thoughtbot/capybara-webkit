require 'spec_helper'
require 'capybara/webkit/connection'

describe Capybara::Webkit::Connection do
  it "sets appropriate options on its socket" do
    socket = double("socket")
    server = double(:Server, start: nil, port: 123)
    allow(TCPSocket).to receive(:open).and_return(socket)
    if defined?(Socket::TCP_NODELAY)
      expect(socket).to receive(:setsockopt).
        with(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, true)
    else
      expect(socket).not_to receive(:setsockopt)
    end

    Capybara::Webkit::Connection.new(server: server)
  end
end
