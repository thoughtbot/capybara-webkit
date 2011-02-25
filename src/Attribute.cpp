#include "Attribute.h"
#include "WebPage.h"

Attribute::Attribute(WebPage *page, QObject *parent) : Command(page, parent) {
}

void Attribute::receivedArgument(const char *argument) {
  m_args.append(argument);
  if (m_args.length() == 2) {
    QString nodeIndex = m_args[0];
    QString attributeName = m_args[1];
    QString javascript = QString("\
        (function () {\
          var node = window.__capybara_nodes[") + nodeIndex + "];\
          return node.getAttribute('" + attributeName + "');\
        })();\
        ";
    QVariant result = page()->mainFrame()->evaluateJavaScript(javascript);
    QString attributeValue = result.toString();
    emit finished(true, attributeValue);
  }
}

