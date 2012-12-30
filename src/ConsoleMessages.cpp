#include "ConsoleMessages.h"
#include "WebPage.h"
#include "WebPageManager.h"
#include "JsonSerializer.h"

ConsoleMessages::ConsoleMessages(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
}

void ConsoleMessages::start() {
  JsonSerializer serializer;
  QString json = serializer.serialize(page()->consoleMessages());
  emitFinished(true, json);
}

