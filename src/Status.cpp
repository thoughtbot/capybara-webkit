#include "Status.h"
#include "WebPage.h"
#include <sstream>

Status::Status(WebPage *page, QObject *parent) : Command(page, parent) {
}

void Status::start(QStringList &arguments) {
  Q_UNUSED(arguments);
  int status = page()->getLastStatus();
  emit finished(new Response(true, QString::number(status)));
}

