#include "JavascriptAlertMessages.h"
#include "WebPage.h"
#include "WebPageManager.h"

JavascriptAlertMessages::JavascriptAlertMessages(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {}

void JavascriptAlertMessages::start()
{
  emitFinished(true, page()->alertMessages());
}
