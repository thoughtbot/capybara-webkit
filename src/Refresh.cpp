#include "Refresh.h"
#include "SocketCommand.h"
#include "WebPage.h"
#include "WebPageManager.h"

Refresh::Refresh(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
}

void Refresh::start() {
  page()->triggerAction(QWebPage::Reload);
  finish(true);
}
