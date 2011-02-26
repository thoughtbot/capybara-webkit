Capybara = {
  nextIndex: 0,
  nodes: {},

  invoke: function () {
    return this[CapybaraInvocation.functionName].apply(this, CapybaraInvocation.arguments);
  },

  find: function (xpath) {
    var iterator = document.evaluate(xpath, document, null, XPathResult.ORDERED_NODE_ITERATOR_TYPE, null);
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
    return this.nodes[index].getAttribute(name);
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
      if (element.style.display == 'none')
        return false;
      element = element.parentElement;
    }
    return true;
  },

  value: function(index) {
    return this.nodes[index].value;
  },

  set: function(index, value) {
    this.nodes[index].value = value;
  }

};

