#include "Headers.h"
#include "WebPage.h"
#include "WebPageManager.h"

Headers::Headers(WebPageManager *manager, QStringList &arguments, QObject *parent) : Command(manager, arguments, parent) {
}

void Headers::start() {
  emit finished(new Response(true, page()->pageHeaders()));
}

