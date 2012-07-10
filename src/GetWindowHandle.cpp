#include "GetWindowHandle.h"
#include "WebPage.h"
#include "WebPageManager.h"
#include <QStringList>

GetWindowHandle::GetWindowHandle(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
}

void GetWindowHandle::start() {
  emit finished(new Response(true, page()->uuid()));
}
