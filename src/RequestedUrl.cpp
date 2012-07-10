#include "RequestedUrl.h"
#include "WebPage.h"
#include "WebPageManager.h"

RequestedUrl::RequestedUrl(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
}

void RequestedUrl::start() {
  QUrl humanUrl = page()->currentFrame()->requestedUrl();
  QByteArray encodedBytes = humanUrl.toEncoded();
  emit finished(new Response(true, encodedBytes));
}

