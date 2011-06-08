#include "Header.h"
#include "WebPage.h"
#include "NetworkAccessManager.h"

Header::Header(WebPage *page, QObject *parent) : Command(page, parent) {
}

void Header::start(QStringList &arguments) {
  QString key = arguments[0];
  QString value = arguments[1];
  NetworkAccessManager* nam = qobject_cast<NetworkAccessManager*>(page()->networkAccessManager());
  if (key.toLower().replace("-", "_") == "user_agent") {
    page()->setUserAgent(value);
  } else {
    nam->addHeader(key, value);
  }
  emit finished(new Response(true));
}
