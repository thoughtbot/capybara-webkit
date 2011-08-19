#include "Headers.h"
#include "WebPage.h"

Headers::Headers(WebPage *page, QObject *parent) : Command(page, parent) {
}

void Headers::start(QStringList &arguments) {
  Q_UNUSED(arguments);
  emit finished(new Response(true, page()->pageHeaders()));
}

