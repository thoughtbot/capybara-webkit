#include "Headers.h"
#include "WebPage.h"

Headers::Headers(WebPage *page, QStringList &arguments, QObject *parent) : Command(page, arguments, parent) {
}

void Headers::start() {
  emit finished(new Response(true, page()->pageHeaders()));
}

