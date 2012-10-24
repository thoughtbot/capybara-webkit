#include "Headers.h"
#include "WebPage.h"
#include "WebPageManager.h"

Headers::Headers(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
}

void Headers::start() {
  QStringList headers;

  foreach(QNetworkReply::RawHeaderPair header, page()->pageHeaders())
    headers << header.first+": "+header.second;

  emit finished(new Response(true, headers.join("\n")));
}

