module Capybara::Webkit
  class Node < Capybara::Driver::Node
    def initialize(session, base, browser)
      super(session, base)
      @browser = browser
    end

    def visible_text
      Capybara::Helpers.normalize_whitespace(invoke("text"))
    end
    alias_method :text, :visible_text

    def all_text
      Capybara::Helpers.normalize_whitespace(invoke("allText"))
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
        self.find_xpath(".//option").select(&:selected?).map(&:value)
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

    def send_keys(*keys)
      # Currently unsupported keys specified by Capybara
      # :separator
      invoke("sendKeys", convert_to_named_keys(keys).to_json)
    end

    def select_option
      invoke "selectOption"
    end

    def unselect_option
      select = find_xpath("ancestor::select").first
      if select.multiple_select?
        invoke "unselectOption"
      else
        raise Capybara::UnselectNotAllowed
      end
    end

    def click
      invoke("leftClick")
    end

    def double_click
      invoke("doubleClick")
    end

    def right_click
      invoke("rightClick")
    end

    def hover
      invoke("hover")
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
      xpath = "parent::optgroup[@disabled] | " \
        "ancestor::select[@disabled] | " \
        "parent::fieldset[@disabled] | " \
        "ancestor::*[not(self::legend) or " \
        "preceding-sibling::legend][parent::fieldset[@disabled]]"

      self["disabled"] || !find_xpath(xpath).empty?
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

    def find_xpath(xpath)
      invoke("findXpathWithin", xpath).split(',').map do |native|
        self.class.new(driver, native, @browser)
      end
    end

    alias_method :find, :find_xpath

    def find_css(selector)
      invoke("findCssWithin", selector).split(',').map do |native|
        self.class.new(driver, native, @browser)
      end
    end

    def invoke(name, *args)
      @browser.command "Node", name, allow_unattached_nodes?, native, *args
    end

    def allow_unattached_nodes?
      !automatic_reload?
    end

    def automatic_reload?
      Capybara.respond_to?(:automatic_reload) && Capybara.automatic_reload
    end

    def attached?
      @browser.command("Node", "isAttached", native) == "true"
    end

    def multiple_select?
      self.tag_name == "select" && self["multiple"]
    end

    def ==(other)
      invoke("equals", other.native) == "true"
    end

    private

    def convert_to_named_keys(key)
      if key.is_a? Array
        key.map { |k| convert_to_named_keys(k)}
      else
        case key
        when :cancel, :help, :backspace, :tab, :clear, :return, :enter, :insert, :delete, :pause, :escape,
             :space, :end, :home, :left, :up, :right, :down, :semicolon,
             :f1, :f2, :f3, :f4, :f5, :f6, :f7, :f8, :f9, :f10, :f11, :f12,
             :shift, :control, :alt, :meta
          { "key" => key.to_s.capitalize }
        when :equals
          { "key" => "Equal" }
        when :page_up
          { "key" => "PageUp" }
        when :page_down
          { "key" => "PageDown" }
        when :numpad0, :numpad1, :numpad2, :numpad3, :numpad4,
             :numpad5, :numpad6, :numpad7, :numpad9, :numpad9
          { "key" => key[-1], "modifier" => "keypad" }
        when :multiply
          { "key" => "Asterisk", "modifier" => "keypad" }
        when :divide
          { "key" => "Slash", "modifier" => "keypad" }
        when :add
          { "key" => "Plus", "modifier" => "keypad" }
        when :subtract
          { "key" => "Minus", "modifier" => "keypad" }
        when :decimal
          { "key" => "Period", "modifier" => "keypad" }
        when :command
          { "key" => "Meta" }
        when String
          key.to_s
        else
          raise Capybara::NotSupportedByDriverError.new
        end
      end
    end
  end
end
