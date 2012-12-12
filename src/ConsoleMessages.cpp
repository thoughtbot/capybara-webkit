#include "ConsoleMessages.h"
#include "WebPage.h"
#include "WebPageManager.h"

ConsoleMessages::ConsoleMessages(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
}

void ConsoleMessages::start() {
  emitFinished(true, page()->consoleMessages());
}

