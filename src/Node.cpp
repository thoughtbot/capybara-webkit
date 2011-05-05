#include "Node.h"
#include "WebPage.h"

Node::Node(WebPage *page, QObject *parent) : Command(page, parent) {
}

void Node::start(QStringList &arguments) {
  QStringList functionArguments(arguments);
  QString functionName = functionArguments.takeFirst();
  QVariant result = page()->invokeCapybaraFunction(functionName, functionArguments);
  QString attributeValue = result.toString();
  emit finished(new Response(true, attributeValue));
}

