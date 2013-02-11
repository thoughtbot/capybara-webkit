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
    return finish(false, result.errorMessage());

  QString message;
  message = result.result().toString();
  finish(true, message);
}

