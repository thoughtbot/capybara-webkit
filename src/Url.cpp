#include "Url.h"
#include "WebPage.h"
#include "WebPageManager.h"

Url::Url(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
}

void Url::start() {
  QUrl humanUrl = page()->currentFrame()->url();
  QByteArray encodedBytes = humanUrl.toEncoded();
  emit finished(new Response(true, encodedBytes));
}

