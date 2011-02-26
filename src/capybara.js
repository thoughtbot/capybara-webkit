Capybara = {
  nextIndex: 0,
  nodes: {},

  find: function (xpath) {
    var iterator = document.evaluate(xpath, document, null, XPathResult.ORDERED_NODE_ITERATOR_TYPE, null);
    var node;
    var results = [];
    while (node = iterator.iterateNext()) {
      this.nextIndex++;
      this.nodes[this.nextIndex] = node;
      results.push(this.nextIndex);
    }
    return results;
  },

  attribute: function (index, name) {
    return this.nodes[index].getAttribute(name);
  }
};

