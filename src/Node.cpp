#include "Node.h"
#include "WebPage.h"
#include "WebPageManager.h"
#include "InvocationResult.h"

Node::Node(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
}

void Node::start() {
  QStringList functionArguments(arguments());
  QString functionName = functionArguments.takeFirst();
  InvocationResult result = page()->invokeCapybaraFunction(functionName, functionArguments);

  if (result.hasError())
    return emitFinished(false, result.errorMessage());

  QString attributeValue = result.result().toString();
  emitFinished(true, attributeValue);
}

QString Node::toString() const {
  QStringList functionArguments(arguments());
  return QString("Node.") + functionArguments.takeFirst();
}
