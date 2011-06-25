#include "Header.h"
#include "WebPage.h"
#include "NetworkAccessManager.h"

Header::Header(WebPage *page, QObject *parent) : Command(page, parent) {
}

void Header::start(QStringList &arguments) {
  QString key = arguments[0];
  QString value = arguments[1];
  NetworkAccessManager* networkAccessManager = qobject_cast<NetworkAccessManager*>(page()->networkAccessManager());
  if (key.toLower().replace("-", "_") == "user_agent") {
    page()->setUserAgent(value);
  } else {
    networkAccessManager->addHeader(key, value);
  }
  emit finished(new Response(true));
}
