#include "Reset.h"
#include "WebPage.h"

Reset::Reset(WebPage *page, QObject *parent) : Command(page, parent) {
}

void Reset::start(QStringList &arguments) {
  Q_UNUSED(arguments);

  page()->triggerAction(QWebPage::Stop);
  page()->mainFrame()->setHtml("<html><body></body></html>");
  page()->networkAccessManager()->setCookieJar(new QNetworkCookieJar());
  QString response = "";
  emit finished(true, response);
}

