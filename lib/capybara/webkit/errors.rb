module Capybara::Webkit
  class InvalidResponseError < StandardError
  end

  class NoResponseError < StandardError
  end

  class NodeNotAttachedError < Capybara::ElementNotFound
  end

  class ClickFailed < StandardError
  end
end
