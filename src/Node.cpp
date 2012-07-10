#include "Node.h"
#include "WebPage.h"
#include "WebPageManager.h"

Node::Node(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
}

void Node::start() {
  QStringList functionArguments(arguments());
  QString functionName = functionArguments.takeFirst();
  QVariant result = page()->invokeCapybaraFunction(functionName, functionArguments);
  QString attributeValue = result.toString();
  emit finished(new Response(true, attributeValue));
}

QString Node::toString() const {
  QStringList functionArguments(arguments());
  return QString("Node.") + functionArguments.takeFirst();
}
