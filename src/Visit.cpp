#include "Visit.h"
#include "Command.h"
#include "WebPage.h"
#include "WebPageManager.h"

Visit::Visit(WebPageManager *manager, QStringList &arguments, QObject *parent) : Command(manager, arguments, parent) {
}

void Visit::start() {
  QUrl requestedUrl = QUrl::fromEncoded(arguments()[0].toUtf8(), QUrl::StrictMode);
  page()->currentFrame()->load(QUrl(requestedUrl));
  emit finished(new Response(true));
}
