#include "Source.h"
#include "WebPage.h"

Source::Source(WebPage *page, QStringList &arguments, QObject *parent) : Command(page, arguments, parent) {
}

void Source::start() {
  QNetworkAccessManager* accessManager = page()->networkAccessManager();
  QNetworkRequest request(page()->currentFrame()->url());
  reply = accessManager->get(request);

  connect(reply, SIGNAL(finished()), this, SLOT(sourceLoaded()));
}

void Source::sourceLoaded() {
  emit finished(new Response(true, reply->readAll()));
}

