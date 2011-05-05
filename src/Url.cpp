#include "Url.h"
#include "WebPage.h"

Url::Url(WebPage *page, QObject *parent) : Command(page, parent) {
}

void Url::start(QStringList &argments) {
  Q_UNUSED(argments);

  QUrl humanUrl = page()->currentFrame()->url();
  QByteArray encodedBytes = humanUrl.toEncoded();
  QString urlString = QString(encodedBytes);
  emit finished(new Response(true, urlString));
}

