#include "FindCss.h"
#include "SocketCommand.h"
#include "WebPage.h"
#include "WebPageManager.h"
#include "InvocationResult.h"

FindCss::FindCss(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
}

void FindCss::start() {
  InvocationResult result = page()->invokeCapybaraFunction("findCss", arguments());

  if (result.hasError())
    return finish(false, result.errorMessage());

  QString message;
  message = result.result().toString();
  finish(true, message);
}

