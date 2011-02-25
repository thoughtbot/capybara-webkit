#include "Find.h"
#include "Command.h"
#include "WebPage.h"
#include <iostream>

Find::Find(WebPage *page, QObject *parent) : Command(page, parent) {
}

void Find::receivedArgument(const char *xpath) {
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

  QString response;
  QVariant result = page()->mainFrame()->evaluateJavaScript(javascript);

  if (result.isValid()) {
    QVariantList nodes = result.toList();
    bool addComma = false;

    double node;
    for (int i = 0; i < nodes.size(); i++) {
      node = nodes[i].toDouble();
      if (addComma)
        response.append(",");
      response.append(QString::number(node));
      addComma = true;
    }

    emit finished(true, response);
  } else {
    response = "Invalid XPath expression";
    emit finished(false, response);
  }
}

