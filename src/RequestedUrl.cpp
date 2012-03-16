#include "RequestedUrl.h"
#include "WebPage.h"

RequestedUrl::RequestedUrl(WebPage *page, QStringList &arguments, QObject *parent) : Command(page, arguments, parent) {
}

void RequestedUrl::start() {
  QUrl humanUrl = page()->currentFrame()->requestedUrl();
  QByteArray encodedBytes = humanUrl.toEncoded();
  QString urlString = QString(encodedBytes);
  emit finished(new Response(true, urlString));
}

