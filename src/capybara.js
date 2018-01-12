Capybara = {
  nextIndex: 0,
  nodes: {},
  attachedFiles: [],
  keyModifiersStack: [],

  invoke: function () {
    try {
      if (CapybaraInvocation.functionName == "leftClick") {
        var args = CapybaraInvocation.arguments;
        var leftClickOptions = this["verifiedClickPosition"].apply(this, args);
        leftClickOptions["keys"] = JSON.parse(args[1]);
        offset = JSON.parse(args[2]);
        if (offset && offset.x && offset.y){
          leftClickOptions["absoluteX"] = leftClickOptions["absoluteLeft"] + offset.x;
          leftClickOptions["absoluteY"] = leftClickOptions["absoluteTop"] + offset.y;
        }
        return leftClickOptions;
      } else {
        return this[CapybaraInvocation.functionName].apply(this, CapybaraInvocation.arguments);
      }
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
    return this.findXpathRelativeTo(this.getNode(index), xpath);
  },

  findCssWithin: function (index, selector) {
    return this.findCssRelativeTo(this.getNode(index), selector);
  },

  findXpathRelativeTo: function (reference, xpath) {
    var iterator = document.evaluate(xpath, reference, null, XPathResult.ORDERED_NODE_ITERATOR_TYPE, null);
    var node;
    var results = [];
    while (node = iterator.iterateNext()) {
      results.push(this.registerNode(node));
    }
    return results.join(",");
  },

  findCssRelativeTo: function (reference, selector) {
    var elements = reference.querySelectorAll(selector);
    var results = [];
    for (var i = 0; i < elements.length; i++) {
      results.push(this.registerNode(elements[i]));
    }
    return results.join(",");
  },

  isAttached: function(index) {
    return this.nodes[index] &&
      document.evaluate("ancestor-or-self::html", this.nodes[index], null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue != null;
  },

  getNode: function(index) {
    if (CapybaraInvocation.allowUnattached || this.isAttached(index)) {
      return this.nodes[index];
    } else {
      throw new Capybara.NodeNotAttachedError(index);
    }
  },

  text: function (index) {
    var node = this.getNode(index);
    var type = node instanceof HTMLFormElement ? 'form' : (node.type || node.tagName).toLowerCase();

    if (!this.isNodeVisible(node)) {
      return '';
    } else if (type == "textarea") {
      return node.innerHTML;
    } else {
      visible_text = node.innerText;
      return typeof visible_text === "string" ? visible_text : node.textContent;
    }
  },

  allText: function (index) {
    var node = this.getNode(index);
    return node.textContent;
  },

  attribute: function (index, name) {
    var node = this.getNode(index);
    if (node.hasAttribute(name)) {
      return node.getAttribute(name);
    }
    return void 0;
  },

  property: function (index, name) {
    var node = this.getNode(index);
    return node[name];
  },

  hasAttribute: function(index, name) {
    return this.getNode(index).hasAttribute(name);
  },

  path: function(index) {
    return this.pathForNode(this.getNode(index));
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
    return this.getNode(index).tagName.toLowerCase();
  },

  submit: function(index) {
    return this.getNode(index).submit();
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
    if(node.namespaceURI == 'http://www.w3.org/2000/svg') {
      var rect = node.getBoundingClientRect();

      if (rect.width > 0 && rect.height > 0)
        return CapybaraInvocation.clickPosition(node, rect.left, rect.top, rect.width, rect.height);
    } else {
      var rects = node.getClientRects();
      var rect;

      for (var i = 0; i < rects.length; i++) {
        rect = rects[i];
        if (rect.width > 0 && rect.height > 0)
          return CapybaraInvocation.clickPosition(node, rect.left, rect.top, rect.width, rect.height);
      }
    }

    var visible = this.isNodeVisible(node);
    throw new Capybara.UnpositionedElement(this.pathForNode(node), visible);
  },

  verifiedClickPosition: function (index) {
    var node = this.getNode(index);
    node.scrollIntoViewIfNeeded();
    var pos = this.clickPosition(node);
    CapybaraInvocation.hover(pos.relativeX, pos.relativeY);
    this.expectNodeAtPosition(node, pos);
    return pos;
  },

  click: function (index, action, keys, offset) {
    var pos = this.verifiedClickPosition(index);
    keys = keys ? JSON.parse(keys) : [];
    offset = offset ? JSON.parse(offset) : {};
    if (offset && (offset.x != null) && (offset.y != null)){
      action(pos.absoluteLeft + offset.x, pos.absoluteTop + offset.y, keys);
    } else {
      action(pos.absoluteX, pos.absoluteY, keys);
    }
  },

  leftClick: function (index, keys, offset) {
    this.click(index, CapybaraInvocation.leftClick, keys, offset);
  },

  doubleClick: function(index, keys, offset) {
    this.click(index, CapybaraInvocation.leftClick, keys, offset);
    this.click(index, CapybaraInvocation.doubleClick, keys, offset);
  },

  rightClick: function(index, keys, offset) {
    this.click(index, CapybaraInvocation.rightClick, keys, offset);
  },

  hover: function (index) {
    var node = this.getNode(index);
    node.scrollIntoViewIfNeeded();

    var pos = this.clickPosition(node);
    CapybaraInvocation.hover(pos.absoluteX, pos.absoluteY);
  },

  trigger: function (index, eventName) {
    this.triggerOnNode(this.getNode(index), eventName);
  },

  triggerOnNode: function(node, eventName) {
    var eventObject = document.createEvent("HTMLEvents");
    eventObject.initEvent(eventName, true, true);
    node.dispatchEvent(eventObject);
  },

  visible: function (index) {
    return this.isNodeVisible(this.getNode(index));
  },

  isNodeVisible: function(node) {
    var style = node.ownerDocument.defaultView.getComputedStyle(node, null);
    // Only check computed visibility style on current node since it
    // will inherit from nearest ancestor with a setting and overrides
    // any farther ancestors
    if (style.getPropertyValue('visibility') == 'hidden' || style.getPropertyValue('display') == 'none')
      return false;

    // Must check CSS display setting for all ancestors
    while (node = node.parentElement) {
      style = node.ownerDocument.defaultView.getComputedStyle(node, null);
      if (style.getPropertyValue('display') == 'none' )
        return false;
    }
    return true;
  },

  selected: function (index) {
    return this.getNode(index).selected;
  },

  value: function(index) {
    return this.getNode(index).value;
  },

  getInnerHTML: function(index) {
    return this.getNode(index).innerHTML;
  },

  setInnerHTML: function(index, value) {
    this.getNode(index).innerHTML = value;
    return true;
  },

  sendKeys: function (elem_index, json_keys) {
    var idx, length, keys;
    keys = JSON.parse(json_keys);
    length = keys.length;

    if (length) {
      this.focus(elem_index);
    }

    for (idx = 0; idx < length; idx++) {
      this._sendKeys(keys[idx]);
    }
  },

  _sendKeys: function(keys) {
    if (typeof keys == "string") {
      var str_len = keys.length;
      var str_idx;
      for (str_idx = 0; str_idx < str_len; str_idx++) {
        CapybaraInvocation.keypress(keys[str_idx]);
      }
    } else if (Array.isArray(keys)) {
      this.keyModifiersStack.push([]);
      var idx;
      for (idx = 0; idx < keys.length; idx++) {
        this._sendKeys(keys[idx]);
      }
      var mods = this.keyModifiersStack.pop();
      while (mods.length) {
        CapybaraInvocation.namedKeyup(mods.pop().key);
      }
    } else {
      key = keys.key;
      if (["Shift", "Control", "Alt", "Meta"].indexOf(key) > -1){
        CapybaraInvocation.namedKeydown(key);
        this.keyModifiersStack[this.keyModifiersStack.length-1].push(keys);
      } else {
        CapybaraInvocation.namedKeypress(key, keys.modifier);
      }
    }
  },

  set: function (index, value) {
    var length, maxLength, node, strindex, textTypes, type;

    node = this.getNode(index);
    type = (node.type || node.tagName).toLowerCase();
    textTypes = ["email", "number", "password", "search", "tel", "text", "textarea", "url"];

    if (textTypes.indexOf(type) != -1) {
      maxLength = this.attribute(index, "maxlength");
      if (maxLength && value.length > maxLength) {
        length = maxLength;
      } else {
        length = value.length;
      }

      if (!node.readOnly) {
        this.focus(index);

        node.value = "";

        for (strindex = 0; strindex < length; strindex++) {
          CapybaraInvocation.keypress(value[strindex]);
        }

        if (value === "") {
          this.trigger(index, "change");
        }
      }
    } else if (type === "checkbox" || type === "radio") {
      if (node.checked != (value === "true")) {
        this.leftClick(index);
      }
    } else if (type === "file") {
      this.attachedFiles = Array.prototype.slice.call(arguments, 1);
      this.leftClick(index);
    } else if (this.isContentEditable(node)) {
      var content = document.createTextNode(value);
      node.innerHTML = '';
      node.appendChild(content);
    } else {
      node.value = value;
    }
  },

  isContentEditable: function(node) {
    if (node.contentEditable == 'true') {
      return true;
    } else if (node.contentEditable == 'false') {
      return false;
    } else if (node.contentEditable == 'inherit') {
      return this.isContentEditable(node.parentNode);
    }
  },

  focus: function(index) {
    this.getNode(index).focus();
  },

  focus_frame: function(index) {
    var elem = this.getNode(index);
    if (elem === document.activeElement) {
      elem.blur();
    }
    elem.focus();
  },

  selectOption: function(index){
    this._setOption(index, true);
  },

  unselectOption: function(index){
    this._setOption(index, false);
  },

  _setOption: function(index, state) {
    var optionNode = this.getNode(index);
    var selectNode = optionNode.parentNode;
    if (selectNode.tagName == "OPTGROUP")
      selectNode = selectNode.parentNode;

    if (optionNode.disabled)
      return;

    if ((!selectNode.multiple) && (!state))
      return;

    // click on select list
    this.triggerOnNode(selectNode, 'mousedown');
    selectNode.focus();
    this.triggerOnNode(selectNode, 'input');

    // select/deselect option from list
    if (optionNode.selected != state){
      optionNode.selected = state;
      this.triggerOnNode(selectNode, 'change');
    }

    this.triggerOnNode(selectNode, 'mouseup');
    this.triggerOnNode(selectNode, 'click');
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
    var element = this.getNode(index), target = this.getNode(targetIndex);
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
  registerNode: function(node) {
    this.nextIndex++;
    this.nodes[this.nextIndex] = node;
    return this.nextIndex;
  },
  equals: function(index, targetIndex) {
    return this.getNode(index) === this.getNode(targetIndex);
  },
  _visitedObjects: [],
  wrapResult: function(arg) {
    if (this._visitedObjects.indexOf(arg) >= 0) { return '(cyclic structure)'; }
    if (arg instanceof NodeList) { arg = Array.prototype.slice.call(arg, 0); }
    if (Array.isArray(arg)) {
      for(var _j = 0; _j < arg.length; _j++) {
        arg[_j] = this.wrapResult(arg[_j]);
      }
    } else if (arg && arg.nodeType == 1 && arg.tagName) {
      return {'element-581e-422e-8be1-884c4e116226': this.registerNode(arg)};
    } else if (arg === null) {
      return undefined;
    } else if (arg instanceof Date){
      return arg;
    } else if ( typeof arg == 'object' ) {
      this._visitedObjects.push(arg);
      var result = {};
      for(var _k in arg){
        result[_k] = this.wrapResult(arg[_k]);
      }
      this._visitedObjects.pop();
      return result;
    }
    return arg;
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
  this.message += "; \nA screenshot of the page at the time of the failure has been written to " + CapybaraInvocation.render();
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

Capybara.NodeNotAttachedError = function(index) {
  this.name = 'Capybara.NodeNotAttachedError';
  this.message = 'Element at ' + index + ' no longer present in the DOM';
};
Capybara.NodeNotAttachedError.prototype = new Error();
Capybara.NodeNotAttachedError.prototype.constructor = Capybara.NodeNotAttachedError;
