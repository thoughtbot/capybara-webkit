#include "Visit.h"
#include "Command.h"
#include "WebPage.h"

Visit::Visit(WebPage *page, QStringList &arguments, QObject *parent) : Command(page, arguments, parent) {
}

void Visit::start() {
  QUrl requestedUrl = QUrl::fromEncoded(arguments()[0].toUtf8(), QUrl::StrictMode);
  if (requestedUrl.hasFragment()) {
  	page()->currentFrame()->load(QUrl(requestedUrl));
  } else {
	page()->currentFrame()->setUrl(QUrl(requestedUrl));
  }
  emit finished(new Response(true));
}
