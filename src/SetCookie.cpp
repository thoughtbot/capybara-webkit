#include "SetCookie.h"
#include "WebPage.h"
#include "WebPageManager.h"
#include "NetworkCookieJar.h"
#include <QNetworkCookie>

SetCookie::SetCookie(WebPageManager *manager, QStringList &arguments, QObject *parent) : Command(manager, arguments, parent) {}

void SetCookie::start()
{
  QList<QNetworkCookie> cookies = QNetworkCookie::parseCookies(arguments()[0].toAscii());
  NetworkCookieJar *jar = qobject_cast<NetworkCookieJar*>(page()
                                                          ->networkAccessManager()
                                                          ->cookieJar());
  jar->overwriteCookies(cookies);
  emit finished(new Response(true));
}
