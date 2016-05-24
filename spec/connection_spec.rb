require 'spec_helper'
require 'capybara/webkit/connection'

describe Capybara::Webkit::Connection do
  it "sets appropriate options on its socket" do
    socket = double("socket")
    server = double(:Server, start: nil, port: 123)
    TCPSocket.stub(:open).and_return(socket)
    if defined?(Socket::TCP_NODELAY)
      socket.
        should_receive(:setsockopt).
        with(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, true)
    else
      socket.should_not_receive(:setsockopt)
    end

    Capybara::Webkit::Connection.new(server: server)
  end
end
