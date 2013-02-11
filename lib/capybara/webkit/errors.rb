module Capybara::Webkit
  module JsonError
    def json_create(attributes)
      new(attributes["message"])
    end
  end

  class InvalidResponseError < StandardError
    extend JsonError
  end

  class NoResponseError < StandardError
  end

  class NodeNotAttachedError < Capybara::ElementNotFound
  end

  class ClickFailed < StandardError
    extend JsonError
  end

  class TimeoutError < Timeout::Error
    extend JsonError
  end
end
