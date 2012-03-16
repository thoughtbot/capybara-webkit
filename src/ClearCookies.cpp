#include "ClearCookies.h"
#include "WebPage.h"
#include "NetworkCookieJar.h"
#include <QNetworkCookie>

ClearCookies::ClearCookies(WebPage *page, QStringList &arguments, QObject *parent) : Command(page, arguments, parent) {}

void ClearCookies::start()
{
  NetworkCookieJar *jar = qobject_cast<NetworkCookieJar*>(page()
                                                          ->networkAccessManager()
                                                          ->cookieJar());
  jar->clearCookies();
  emit finished(new Response(true));
}
