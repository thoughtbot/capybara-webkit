module Capybara::Webkit
  class Node < Capybara::Driver::Node
    NBSP = "\xC2\xA0"
    NBSP.force_encoding("UTF-8") if NBSP.respond_to?(:force_encoding)

    def text
      invoke("text").gsub(NBSP, ' ').gsub(/\s+/u, ' ').strip
    end

    def [](name)
      value = invoke("attribute", name)
      if name == 'checked' || name == 'disabled' || name == 'multiple'
        value == 'true'
      else
        if invoke("hasAttribute", name) == 'true'
          value
        else
          nil
        end
      end
    end

    def value
      if multiple_select?
        self.find(".//option").select(&:selected?).map(&:value)
      else
        invoke "value"
      end
    end

    def inner_html
      invoke 'getInnerHTML'
    end

    def inner_html=(value)
      invoke 'setInnerHTML', value
    end

    def set(value)
      invoke "set", *[value].flatten
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
      unless invoke("click") == "true"
        raise Capybara::Webkit::ClickFailed
      end
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
      invoke "path"
    end

    def submit(opts = {})
      invoke "submit"
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
      if allow_unattached_nodes? || attached?
        browser.command "Node", name, native, *args
      else
        raise Capybara::Webkit::NodeNotAttachedError
      end
    end

    def allow_unattached_nodes?
      !automatic_reload?
    end

    def automatic_reload?
      Capybara.respond_to?(:automatic_reload) && Capybara.automatic_reload
    end

    def attached?
      browser.command("Node", "isAttached", native) == "true"
    end

    def browser
      driver.browser
    end

    def multiple_select?
      self.tag_name == "select" && self["multiple"]
    end

    def ==(other)
      invoke("equals", other.native) == "true"
    end
  end
end
