#include "RequestedUrl.h"
#include "WebPage.h"

RequestedUrl::RequestedUrl(WebPage *page, QObject *parent) : Command(page, parent) {
}

void RequestedUrl::start(QStringList &arguments) {
  Q_UNUSED(arguments);

  QUrl humanUrl = page()->currentFrame()->requestedUrl();
  QByteArray encodedBytes = humanUrl.toEncoded();
  QString urlString = QString(encodedBytes);
  emit finished(new Response(true, urlString));
}

