#include "EnableLogging.h"
#include "WebPageManager.h"

EnableLogging::EnableLogging(WebPageManager *manager, QStringList &arguments, QObject *parent) : Command(manager, arguments, parent) {
}

void EnableLogging::start() {
  manager()->enableLogging();
  emit finished(new Response(true));
}
