#include "Source.h"
#include "WebPage.h"
#include "WebPageManager.h"

Source::Source(WebPageManager *manager, QStringList &arguments, QObject *parent) : Command(manager, arguments, parent) {
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

