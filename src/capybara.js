Capybara = {
  nextIndex: 0,
  nodes: {},

  invoke: function () {
    return this[CapybaraInvocation.functionName].apply(this, CapybaraInvocation.arguments);
  },

  find: function (xpath) {
    return this.findRelativeTo(document, xpath);
  },

  findWithin: function (index, xpath) {
    return this.findRelativeTo(this.nodes[index], xpath);
  },

  findRelativeTo: function (reference, xpath) {
    var iterator = document.evaluate(xpath, reference, null, XPathResult.ORDERED_NODE_ITERATOR_TYPE, null);
    var node;
    var results = [];
    while (node = iterator.iterateNext()) {
      this.nextIndex++;
      this.nodes[this.nextIndex] = node;
      results.push(this.nextIndex);
    }
    return results.join(",");
  },

  text: function (index) {
    return this.nodes[index].innerText;
  },

  attribute: function (index, name) {
    if (name == "checked") {
      return this.nodes[index].checked;
    } else {
      return this.nodes[index].getAttribute(name);
    }
  },

  tagName: function(index) {
    return this.nodes[index].tagName.toLowerCase();
  },

  click: function (index) {
    var clickEvent = document.createEvent('MouseEvents');
    clickEvent.initMouseEvent('click', true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
    this.nodes[index].dispatchEvent(clickEvent);
  },

  trigger: function (index, eventName) {
    var eventObject = document.createEvent("HTMLEvents");
    eventObject.initEvent(eventName, true, true);
    this.nodes[index].dispatchEvent(eventObject);
  },

  visible: function (index) {
    var element = this.nodes[index];
    while (element) {
      if (element.ownerDocument.defaultView.getComputedStyle(element, null).getPropertyValue("display") == 'none')
        return false;
      element = element.parentElement;
    }
    return true;
  },

  value: function(index) {
    return this.nodes[index].value;
  },

  set: function(index, value) {
    var node = this.nodes[index];
    var type = (node.type || node.tagName).toLowerCase();
    if (type == "text" || type == "textarea" || type == "password") {
      this.trigger(index, "focus");
      node.value = value;
      this.trigger(index, "keydown");
      this.trigger(index, "keyup");
      this.trigger(index, "change");
      this.trigger(index, "blur");
    } else if(type == "checkbox" || type == "radio") {
      node.checked = (value == "true");
      this.trigger(index, "click");
    } else {
      node.value = value;
    }
  },

  selectOption: function(index) {
    this.nodes[index].setAttribute("selected", "selected");
  },

  unselectOption: function(index) {
    this.nodes[index].removeAttribute("selected");
  }

};

