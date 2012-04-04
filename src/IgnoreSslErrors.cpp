#include "IgnoreSslErrors.h"
#include "WebPage.h"
#include "WebPageManager.h"

IgnoreSslErrors::IgnoreSslErrors(WebPageManager *manager, QStringList &arguments, QObject *parent) :
  Command(manager, arguments, parent) {
}

void IgnoreSslErrors::start() {
  page()->ignoreSslErrors();
  emit finished(new Response(true));
}

