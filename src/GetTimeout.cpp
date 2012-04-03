#include "GetTimeout.h"
#include "WebPage.h"

GetTimeout::GetTimeout(WebPage *page, QStringList &arguments, QObject *parent) : Command(page, arguments, parent) {
}

void GetTimeout::start() {
  emit finished(new Response(true, QString::number(page()->getTimeout())));
}
