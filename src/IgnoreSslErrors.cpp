#include "IgnoreSslErrors.h"
#include "WebPage.h"

IgnoreSslErrors::IgnoreSslErrors(WebPage *page, QStringList &arguments, QObject *parent) :
  Command(page, arguments, parent) {
}

void IgnoreSslErrors::start() {
  page()->ignoreSslErrors();
  emit finished(new Response(true));
}

