class Capybara::Driver::Webkit
  class Node < Capybara::Driver::Node
    def text
      invoke "text"
    end

    def [](name)
      invoke "attribute", name
    end

    def value
      raise NotImplementedError
    end

    def set(value)
      raise NotImplementedError
    end

    def select_option
      raise NotImplementedError
    end

    def unselect_option
      raise NotImplementedError
    end

    def click
      invoke "click"
    end

    def drag_to(element)
      raise NotImplementedError
    end

    def tag_name
      invoke "tagName"
    end

    def visible?
      raise NotImplementedError
    end

    def path
      raise NotSupportedByDriverError
    end

    def trigger(event)
      invoke "trigger", event
    end

    def invoke(name, *args)
      browser.command "Node", name, native, *args
    end

    def browser
      driver.browser
    end
  end
end

