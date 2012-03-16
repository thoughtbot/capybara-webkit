#include "Status.h"
#include "WebPage.h"
#include <sstream>

Status::Status(WebPage *page, QStringList &arguments, QObject *parent) : Command(page, arguments, parent) {
}

void Status::start() {
  int status = page()->getLastStatus();
  emit finished(new Response(true, QString::number(status)));
}

