#include "Status.h"
#include "WebPage.h"
#include "WebPageManager.h"
#include <sstream>

Status::Status(WebPageManager *manager, QStringList &arguments, QObject *parent) : Command(manager, arguments, parent) {
}

void Status::start() {
  int status = page()->getLastStatus();
  emit finished(new Response(true, QString::number(status)));
}

