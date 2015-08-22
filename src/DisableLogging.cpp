#include "DisableLogging.h"
#include "WebPageManager.h"

DisableLogging::DisableLogging(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
}

void DisableLogging::start() {
  manager()->setLogging(false);
  finish(true);
}
