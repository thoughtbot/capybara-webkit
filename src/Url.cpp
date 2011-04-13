#include "Url.h"
#include "WebPage.h"

Url::Url(WebPage *page, QObject *parent) : Command(page, parent) {
}

void Url::start(QStringList &argments) {
  Q_UNUSED(argments);

  QUrl humanUrl = page()->mainFrame()->url();
  QByteArray encodedBytes = humanUrl.toEncoded();
  QString response = QString(encodedBytes);

  emit finished(true, response);
}

