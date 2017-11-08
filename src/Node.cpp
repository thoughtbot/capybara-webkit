#include "Node.h"
#include "WebPage.h"
#include "WebPageManager.h"
#include "JsonSerializer.h"
#include "InvocationResult.h"

Node::Node(WebPageManager *manager, QStringList &arguments, QObject *parent) : JavascriptCommand(manager, arguments, parent) {
}

void Node::start() {
  QStringList functionArguments(arguments());
  QString functionName = functionArguments.takeFirst();
  QString allowUnattached = functionArguments.takeFirst();
  InvocationResult result = page()->invokeCapybaraFunction(functionName, allowUnattached == "true", functionArguments);
  if (functionName == "focus_frame") {
    page()->setCurrentFrameParent(page()->currentFrame()->parentFrame());
  }

  if (result.hasError()) {
    finish(&result);
  } else {
    JsonSerializer serializer;
    InvocationResult jsonResult = InvocationResult(serializer.serialize(result.result()));
    finish(&jsonResult);
  }
}

QString Node::toString() const {
  QStringList functionArguments(arguments());
  return QString("Node.") + functionArguments.takeFirst();
}
