Capybara = {
  nextIndex: 0,
  nodes: {},
  attachedFiles: [],

  invoke: function () {
    try {
      return this[CapybaraInvocation.functionName].apply(this, CapybaraInvocation.arguments);
    } catch (e) {
      CapybaraInvocation.error = e;
    }
  },

  findXpath: function (xpath) {
    return this.findXpathRelativeTo(document, xpath);
  },

  findCss: function (selector) {
    return this.findCssRelativeTo(document, selector);
  },

  findXpathWithin: function (index, xpath) {
    return this.findXpathRelativeTo(this.nodes[index], xpath);
  },

  findCssWithin: function (index, selector) {
    return this.findCssRelativeTo(this.nodes[index], selector);
  },

  findXpathRelativeTo: function (reference, xpath) {
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

  findCssRelativeTo: function (reference, selector) {
    var elements = reference.querySelectorAll(selector);
    var results = [];
    for (var i = 0; i < elements.length; i++) {
      this.nextIndex++;
      this.nodes[this.nextIndex] = elements[i];
      results.push(this.nextIndex);
    }
    return results.join(",");
  },

  isAttached: function(index) {
    return this.nodes[index] &&
      document.evaluate("ancestor-or-self::html", this.nodes[index], null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue != null;
  },

  text: function (index) {
    var node = this.nodes[index];
    var type = (node.type || node.tagName).toLowerCase();
    if (type == "textarea") {
      return node.innerHTML;
    } else {
      return node.innerText || node.textContent;
    }
  },

  allText: function (index) {
    var node = this.nodes[index];
    return node.textContent;
  },

  attribute: function (index, name) {
    switch(name) {
    case 'checked':
      return this.nodes[index].checked;
      break;

    case 'disabled':
      return this.nodes[index].disabled;
      break;

    case 'multiple':
      return this.nodes[index].multiple;
      break;

    default:
      return this.nodes[index].getAttribute(name);
    }
  },

  hasAttribute: function(index, name) {
    return this.nodes[index].hasAttribute(name);
  },

  path: function(index) {
    return this.pathForNode(this.nodes[index]);
  },

  pathForNode: function(node) {
    return "/" + this.getXPathNode(node).join("/");
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

  expectNodeAtPosition: function(node, pos) {
    var nodeAtPosition =
      document.elementFromPoint(pos.relativeX, pos.relativeY);
    var overlappingPath;

    if (nodeAtPosition)
      overlappingPath = this.pathForNode(nodeAtPosition)

    if (!this.isNodeOrChildAtPosition(node, pos, nodeAtPosition))
      throw new Capybara.ClickFailed(
        this.pathForNode(node),
        overlappingPath,
        pos
      );
  },

  isNodeOrChildAtPosition: function(expectedNode, pos, currentNode) {
    if (currentNode == expectedNode) {
      return CapybaraInvocation.clickTest(
        expectedNode,
        pos.absoluteX,
        pos.absoluteY
      );
    } else if (currentNode) {
      return this.isNodeOrChildAtPosition(
        expectedNode,
        pos,
        currentNode.parentNode
      );
    } else {
      return false;
    }
  },

  clickPosition: function(node) {
    var rects = node.getClientRects();
    var rect;

    for (var i = 0; i < rects.length; i++) {
      rect = rects[i];
      if (rect.width > 0 && rect.height > 0)
        return CapybaraInvocation.clickPosition(node, rect.left, rect.top, rect.width, rect.height);
    }

    var visible = this.isNodeVisible(node);
    throw new Capybara.UnpositionedElement(this.pathForNode(node), visible);
  },

  click: function (index, action) {
    var node = this.nodes[index];
    node.scrollIntoViewIfNeeded();
    var pos = this.clickPosition(node);
    this.expectNodeAtPosition(node, pos);
    action(pos.absoluteX, pos.absoluteY);
  },

  leftClick: function (index) {
    this.click(index, CapybaraInvocation.leftClick);
  },

  doubleClick: function(index) {
    this.click(index, CapybaraInvocation.leftClick);
    this.click(index, CapybaraInvocation.doubleClick);
  },

  rightClick: function(index) {
    this.click(index, CapybaraInvocation.rightClick);
  },

  hover: function (index) {
    var node = this.nodes[index];
    node.scrollIntoViewIfNeeded();

    var pos = this.clickPosition(node);
    CapybaraInvocation.hover(pos.absoluteX, pos.absoluteY);
  },

  trigger: function (index, eventName) {
    var eventObject = document.createEvent("HTMLEvents");
    eventObject.initEvent(eventName, true, true);
    this.nodes[index].dispatchEvent(eventObject);
  },

  visible: function (index) {
    return this.isNodeVisible(this.nodes[index]);
  },

  isNodeVisible: function(node) {
    while (node) {
      var style = node.ownerDocument.defaultView.getComputedStyle(node, null);
      if (style.getPropertyValue('display') == 'none' || style.getPropertyValue('visibility') == 'hidden')
        return false;

      node = node.parentElement;
    }
    return true;
  },

  selected: function (index) {
    return this.nodes[index].selected;
  },

  value: function(index) {
    return this.nodes[index].value;
  },

  getInnerHTML: function(index) {
    return this.nodes[index].innerHTML;
  },

  setInnerHTML: function(index, value) {
    this.nodes[index].innerHTML = value;
    return true;
  },

  set: function (index, value) {
    var length, maxLength, node, strindex, textTypes, type;

    node = this.nodes[index];
    type = (node.type || node.tagName).toLowerCase();
    textTypes = ["email", "number", "password", "search", "tel", "text", "textarea", "url"];

    if (textTypes.indexOf(type) != -1) {
      this.focus(index);

      maxLength = this.attribute(index, "maxlength");
      if (maxLength && value.length > maxLength) {
        length = maxLength;
      } else {
        length = value.length;
      }

      if (!node.readOnly)
        node.value = "";

      for (strindex = 0; strindex < length; strindex++) {
        CapybaraInvocation.keypress(value[strindex]);
      }

    } else if (type === "checkbox" || type === "radio") {
      if (node.checked != (value === "true")) {
        this.leftClick(index);
      }

    } else if (type === "file") {
      this.attachedFiles = Array.prototype.slice.call(arguments, 1);
      this.leftClick(index);

    } else {
      node.value = value;
    }
  },

  focus: function(index) {
    this.nodes[index].focus();
  },

  selectOption: function(index) {
    this.nodes[index].selected = true;
    this.trigger(index, "change");
  },

  unselectOption: function(index) {
    this.nodes[index].selected = false;
    this.trigger(index, "change");
  },

  centerPosition: function(element) {
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
    position.x = Math.floor(position.x);
    position.y = Math.floor(position.y);

    return position;
  },

  reflow: function(element, force) {
    if (force || element.offsetWidth === 0) {
      var prop, oldStyle = {}, newStyle = {position: "absolute", visibility : "hidden", display: "block" };
      for (prop in newStyle)  {
        oldStyle[prop] = element.style[prop];
        element.style[prop] = newStyle[prop];
      }
      // force reflow
      element.offsetWidth;
      element.offsetHeight;
      for (prop in oldStyle)
        element.style[prop] = oldStyle[prop];
    }
  },

  dragTo: function (index, targetIndex) {
    var element = this.nodes[index], target = this.nodes[targetIndex];
    var position = this.centerPosition(element);
    var options = {
      clientX: position.x,
      clientY: position.y
    };
    var mouseTrigger = function(eventName, options) {
      var eventObject = document.createEvent("MouseEvents");
      eventObject.initMouseEvent(eventName, true, true, window, 0, 0, 0, options.clientX || 0, options.clientY || 0, false, false, false, false, 0, null);
      element.dispatchEvent(eventObject);
    };
    mouseTrigger('mousedown', options);
    options.clientX += 1;
    options.clientY += 1;
    mouseTrigger('mousemove', options);

    position = this.centerPosition(target);
    options = {
      clientX: position.x,
      clientY: position.y
    };
    mouseTrigger('mousemove', options);
    mouseTrigger('mouseup', options);
  },

  equals: function(index, targetIndex) {
    return this.nodes[index] === this.nodes[targetIndex];
  }
};

Capybara.ClickFailed = function(expectedPath, actualPath, position) {
  this.name = 'Capybara.ClickFailed';
  this.message = 'Failed to click element ' + expectedPath;
  if (actualPath)
    this.message += ' because of overlapping element ' + actualPath;
  if (position)
    this.message += ' at position ' + position["absoluteX"] + ', ' + position["absoluteY"];
  else
    this.message += ' at unknown position';
};
Capybara.ClickFailed.prototype = new Error();
Capybara.ClickFailed.prototype.constructor = Capybara.ClickFailed;

Capybara.UnpositionedElement = function(path, visible) {
  this.name = 'Capybara.ClickFailed';
  this.message = 'Failed to find position for element ' + path;
  if (!visible)
    this.message += ' because it is not visible';
};
Capybara.UnpositionedElement.prototype = new Error();
Capybara.UnpositionedElement.prototype.constructor = Capybara.UnpositionedElement;
