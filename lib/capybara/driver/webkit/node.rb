class Capybara::Driver::Webkit
  class Node < Capybara::Driver::Node
    def text
      invoke "text"
    end

    def [](name)
      value = invoke("attribute", name)
      if name == 'checked' || name == 'disabled'
        value == 'true'
      else
        value
      end
    end

    def value
      if multiple_select?
        self.find(".//option").select do |option|
          option["selected"] == "selected"
        end.map do |option|
          option.value
        end
      else
        invoke "value"
      end
    end

    def set(value)
      invoke "set", value
    end

    def select_option
      invoke "selectOption"
    end

    def unselect_option
      select = find("ancestor::select").first
      if select.multiple_select?
        invoke "unselectOption"
      else
        raise Capybara::UnselectNotAllowed
      end
    end

    def click
      invoke "click"
    end

    def drag_to(element)
      invoke 'dragTo', element.native
    end

    def tag_name
      invoke "tagName"
    end

    def visible?
      invoke("visible") == "true"
    end

    def selected?
      invoke("selected") == "true"
    end

    def checked?
      self['checked']
    end

    def disabled?
      self['disabled']
    end

    def path
      raise Capybara::NotSupportedByDriverError
    end

    def trigger(event)
      invoke "trigger", event
    end

    def find(xpath)
      invoke("findWithin", xpath).split(',').map do |native|
        self.class.new(driver, native)
      end
    end

    def invoke(name, *args)
      browser.command "Node", name, native, *args
    end

    def browser
      driver.browser
    end

    def multiple_select?
      self.tag_name == "select" && self["multiple"] == "multiple"
    end
  end
end
