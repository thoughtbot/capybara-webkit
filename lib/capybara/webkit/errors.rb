module Capybara::Webkit
  class InvalidResponseError < StandardError
    def self.json_create(o)
      new(o["message"])
    end
  end

  class NoResponseError < StandardError
  end

  class NodeNotAttachedError < Capybara::ElementNotFound
  end

  class ClickFailed < StandardError
    def self.json_create(o)
      new(o["message"])
    end
  end

  class TimeoutError < Timeout::Error
    def self.json_create(o)
      new(o["message"])
    end
  end
end
