#include "Reset.h"
#include "WebPage.h"
#include "NetworkAccessManager.h"
#include "NetworkCookieJar.h"

Reset::Reset(WebPage *page, QStringList &arguments, QObject *parent) : Command(page, arguments, parent) {
}

void Reset::start() {
  page()->triggerAction(QWebPage::Stop);

  NetworkAccessManager* networkAccessManager = qobject_cast<NetworkAccessManager*>(page()->networkAccessManager());
  networkAccessManager->setCookieJar(new NetworkCookieJar());
  networkAccessManager->resetHeaders();

  page()->setUserAgent(NULL);
  page()->resetResponseHeaders();
  page()->resetConsoleMessages();
  page()->resetWindowSize();
  resetHistory();
  emit finished(new Response(true));
}

void Reset::resetHistory() {
  // Clearing the history preserves the current history item, so set it to blank first.
  page()->currentFrame()->setUrl(QUrl("about:blank"));
  page()->history()->clear();
}

