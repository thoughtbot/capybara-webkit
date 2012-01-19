#include "Reset.h"
#include "WebPage.h"
#include "NetworkAccessManager.h"
#include "NetworkCookieJar.h"

Reset::Reset(WebPage *page, QObject *parent) : Command(page, parent) {
}

void Reset::start(QStringList &arguments) {
  Q_UNUSED(arguments);

  page()->triggerAction(QWebPage::Stop);
  page()->currentFrame()->setHtml("<html><body></body></html>");
  page()->networkAccessManager()->setCookieJar(new NetworkCookieJar());
  page()->setCustomNetworkAccessManager();
  page()->setUserAgent(NULL);
  page()->resetResponseHeaders();
  page()->resetConsoleMessages();
  emit finished(new Response(true));
}

