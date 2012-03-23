#include "Node.h"
#include "WebPage.h"

Node::Node(WebPage *page, QStringList &arguments, QObject *parent) : Command(page, arguments, parent) {
}

void Node::start() {
  QStringList functionArguments(arguments());
  QString functionName = functionArguments.takeFirst();
  QVariant result = page()->invokeCapybaraFunction(functionName, functionArguments);
  QString attributeValue = result.toString();
  emit finished(new Response(true, attributeValue));
}

