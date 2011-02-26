#include "Url.h"
#include "WebPage.h"

Url::Url(WebPage *page, QObject *parent) : Command(page, parent) {
}

void Url::start(QStringList &argments) {
  Q_UNUSED(argments);

  QString response = page()->mainFrame()->url().toString();

  emit finished(true, response);
}

