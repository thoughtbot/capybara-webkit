Capybara = {
  nextIndex: 0,
  nodes: {},
  lastAttachedFile: "",

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

  isAttached: function(index) {
    return document.evaluate("ancestor-or-self::html", this.nodes[index], null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue != null;
  },

  text: function (index) {
    var node = this.nodes[index];
    var type = (node.type || node.tagName).toLowerCase();
    if (type == "textarea") {
      return node.innerHTML;
    } else {
      return node.innerText;
    }
  },

  attribute: function (index, name) {
    switch(name) {
    case 'checked':
      return this.nodes[index].checked;
      break;

    case 'disabled':
      return this.nodes[index].disabled;
      break;

    default:
      return this.nodes[index].getAttribute(name);
    }
  },

  path: function(index) {
    return "/" + this.getXPathNode(this.nodes[index]).join("/");
  },

  getXPathNode: function(node, path) {
    path = path || [];
    if (node.parentNode) {
      path = this.getXPathNode(node.parentNode, path);
    }

    var first = node;
    while (first.previousSibling)
      first = first.previousSibling;

    var count = 0;
    var index = 0;
    var iter = first;
    while (iter) {
      if (iter.nodeType == 1 && iter.nodeName == node.nodeName)
        count++;
      if (iter.isSameNode(node))
         index = count;
      iter = iter.nextSibling;
      continue;
    }

    if (node.nodeType == 1)
      path.push(node.nodeName.toLowerCase() + (node.id ? "[@id='"+node.id+"']" : count > 1 ? "["+index+"]" : ''));

    return path;
  },

  tagName: function(index) {
    return this.nodes[index].tagName.toLowerCase();
  },

  submit: function(index) {
    return this.nodes[index].submit();
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

  keypress: function(index, altKey, ctrlKey, shiftKey, metaKey, keyCode, charCode) {
    var eventObject = document.createEvent("Events");
    eventObject.initEvent('keypress', true, true);
    eventObject.window = window;
    eventObject.altKey = altKey;
    eventObject.ctrlKey = ctrlKey;
    eventObject.shiftKey = shiftKey;
    eventObject.metaKey = metaKey;
    eventObject.keyCode = keyCode;
    eventObject.charCode = charCode;
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

  selected: function (index) {
    return this.nodes[index].selected;
  },

  value: function(index) {
    return this.nodes[index].value;
  },

  set: function(index, value) {
    var node = this.nodes[index];
    var type = (node.type || node.tagName).toLowerCase();
    if (type == "text" || type == "textarea" || type == "password" || type == "email") {
      this.trigger(index, "focus");
      node.value = "";
      var maxLength = this.attribute(index, "maxlength"),
          length;
      if (maxLength && value.length > maxLength) {
        length = maxLength;
      } else {
        length = value.length;
      }

      for(var strindex = 0; strindex < length; strindex++) {
        node.value += value[strindex];
        this.trigger(index, "keydown");
        this.keypress(index, false, false, false, false, 0, value[strindex]);
        this.trigger(index, "keyup");
      }
      this.trigger(index, "change");
      this.trigger(index, "blur");
    } else if(type == "checkbox" || type == "radio") {
      node.checked = (value == "true");
      this.trigger(index, "click");
      this.trigger(index, "change");
    } else if(type == "file") {
      this.lastAttachedFile = value;
      this.trigger(index, "click");
    } else {
      node.value = value;
    }
  },

  selectOption: function(index) {
    this.nodes[index].selected = true;
    this.nodes[index].setAttribute("selected", "selected");
    this.trigger(index, "change");
  },

  unselectOption: function(index) {
    this.nodes[index].selected = false;
    this.nodes[index].removeAttribute("selected");
    this.trigger(index, "change");
  },

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

