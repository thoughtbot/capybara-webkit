#include "SetCookie.h"
#include "WebPage.h"
#include "NetworkCookieJar.h"
#include <QNetworkCookie>

SetCookie::SetCookie(WebPage *page, QObject *parent)
  : Command(page, parent)
{ }

void SetCookie::start(QStringList &arguments)
{
  QList<QNetworkCookie> cookies = QNetworkCookie::parseCookies(arguments[0].toAscii());
  NetworkCookieJar *jar = qobject_cast<NetworkCookieJar*>(page()
                                                          ->networkAccessManager()
                                                          ->cookieJar());
  jar->overwriteCookies(cookies);
  emit finished(new Response(true));
}
