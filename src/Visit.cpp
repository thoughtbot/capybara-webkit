#include "Visit.h"
#include "Command.h"
#include "WebPage.h"

Visit::Visit(WebPage *page, QObject *parent) : Command(page, parent) {
}

void Visit::start(QStringList &arguments) {
  QUrl requestedUrl = QUrl::fromEncoded(arguments[0].toUtf8(), QUrl::StrictMode);
  page()->currentFrame()->load(QUrl(requestedUrl));
  emit finished(new Response(true));
}
