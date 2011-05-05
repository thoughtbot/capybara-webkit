#include "Reset.h"
#include "WebPage.h"

Reset::Reset(WebPage *page, QObject *parent) : Command(page, parent) {
}

void Reset::start(QStringList &arguments) {
  Q_UNUSED(arguments);

  page()->triggerAction(QWebPage::Stop);
  page()->currentFrame()->setHtml("<html><body></body></html>");
  page()->networkAccessManager()->setCookieJar(new QNetworkCookieJar());
  emit finished(new Response(true));
}

