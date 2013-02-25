#include "JavascriptCommand.h"
#include "WebPageManager.h"
#include "InvocationResult.h"

JavascriptCommand::JavascriptCommand(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
}

void JavascriptCommand::finish(InvocationResult *result) {
  if (result->hasError())
    return SocketCommand::finish(false, result->errorMessage());

  QString message = result->result().toString();
  SocketCommand::finish(true, message);
}
