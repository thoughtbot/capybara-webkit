#include "Find.h"
#include "SocketCommand.h"
#include "WebPage.h"
#include "WebPageManager.h"
#include "InvocationResult.h"

Find::Find(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
}

void Find::start() {
  InvocationResult result = page()->invokeCapybaraFunction("find", arguments());

  if (result.hasError())
    return emitFinished(false, QString("Invalid XPath expression"));

  QString message;
  message = result.result().toString();
  emitFinished(true, message);
}

