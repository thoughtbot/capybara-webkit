#include "Find.h"
#include "Command.h"
#include "WebPage.h"
#include <iostream>

Find::Find(WebPage *page, QObject *parent) : Command(page, parent) {
}

void Find::receivedArgument(const char *xpath) {
  std::cout << "<< Running query: " << xpath << std::endl;
  QString javascript = QString("\
      (function () {\
        if (!window.__capybara_index) {\
          window.__capybara_index = 0;\
          window.__capybara_nodes = {};\
        }\
        var iterator = document.evaluate(\"") + xpath + "\",\
          document,\
          null,\
          XPathResult.ORDERED_NODE_ITERATOR_TYPE,\
          null);\
        var node;\
        var results = [];\
        while (node = iterator.iterateNext()) {\
          window.__capybara_index++;\
          window.__capybara_nodes[window.__capybara_index] = node;\
          results.push(window.__capybara_index);\
        }\
        return results;\
      })()\
  ";


  std::cout << "<< Javascript to execute:" << std::endl;
  std::cout << javascript.toAscii().data() << std::endl;

  QVariant result = page()->mainFrame()->evaluateJavaScript(javascript);

  QVariantList nodes = result.toList();
  QString response;
  bool addComma = false;

  double node;
  for (int i = 0; i < nodes.size(); i++) {
    node = nodes[i].toDouble();
    if (addComma)
      response.append(",");
    response.append(QString::number(node));
    addComma = true;
  }

  std::cout << "<< Got result:" << std::endl;
  std::cout << response.toAscii().data() << std::endl;

  emit finished(true, response);
}

