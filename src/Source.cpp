#include "Source.h"
#include "WebPage.h"

Source::Source(WebPage *page, QObject *parent) : Command(page, parent) {
}

void Source::start(QStringList &arguments) {
  Q_UNUSED(arguments)

  QNetworkAccessManager* accessManager = page()->networkAccessManager();
  QNetworkRequest request(page()->currentFrame()->url());
  reply = accessManager->get(request);

  connect(reply, SIGNAL(finished()), this, SLOT(sourceLoaded()));
}

void Source::sourceLoaded() {
  emit finished(new Response(true, reply->readAll()));
}

