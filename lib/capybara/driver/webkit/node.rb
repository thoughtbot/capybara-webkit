class Capybara::Driver::Webkit
  class Node < Capybara::Driver::Node
    def text
      invoke "text"
    end

    def [](name)
      value = invoke("attribute", name)
      if name == 'checked'
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
      invoke "unselectOption"
    end

    def click
      invoke "click"
    end

    def drag_to(element)
      inject_drag_to_script
      invoke 'dragTo', element.native
    end

    def tag_name
      invoke "tagName"
    end

    def visible?
      invoke("visible") == "true"
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

    private

    def multiple_select?
      self.tag_name == "select" && self["multiple"] == "multiple"
    end

    def inject_drag_to_script
      # FIXME
      # If this code append to src/capybara.js, raise ReferenceError ...
      # 'undefined:1 ReferenceError: Can't find variable: Capybara'
      unless @injected_drag_to_script
        browser.evaluate_script <<-JS
(function() {
  var InjectCode = {
    centerPostion: function(element) {
      this.reflow(element);
      var rect = element.getBoundingClientRect();
      var position = {
        x: rect.width / 2,
        y: rect.height / 2
      };
      do {
          position.x += element.offsetLeft;
          position.y += element.offsetTop;
      } while ((element = element.offsetParent));
      position.x = Math.floor(position.x), position.y = Math.floor(position.y);

      return position;
    },

    reflow: function(element, force) {
      if (force || element.offsetWidth === 0) {
        var prop, oldStyle = {}, newStyle = {position: "absolute", visibility : "hidden", display: "block" };
        for (prop in newStyle)  {
          oldStyle[prop] = element.style[prop];
          element.style[prop] = newStyle[prop];
        }
        element.offsetWidth, element.offsetHeight; // force reflow
        for (prop in oldStyle)
          element.style[prop] = oldStyle[prop];
      }
    },

    dragTo: function (index, targetIndex) {
      var element = this.nodes[index], target = this.nodes[targetIndex];
      var position = this.centerPostion(element);
      var options = {
        clientX: position.x,
        clientY: position.y
      };
      var mouseTrigger = function(eventName, options) {
        var eventObject = document.createEvent("MouseEvents");
        eventObject.initMouseEvent(eventName, true, true, window, 0, 0, 0, options.clientX || 0, options.clientY || 0, false, false, false, false, 0, null);
        element.dispatchEvent(eventObject);
      }
      mouseTrigger('mousedown', options);
      options.clientX += 1, options.clientY += 1;
      mouseTrigger('mousemove', options);

      position = this.centerPostion(target), options = {
        clientX: position.x,
        clientY: position.y
      };
      mouseTrigger('mousemove', options);
      mouseTrigger('mouseup', options);
    }
  };
  for (var prop in InjectCode) Capybara[prop] = InjectCode[prop];
})();
        JS
        @injected_drag_to_script = true
      end
    end
  end
end
