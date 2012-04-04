#include "ClearCookies.h"
#include "WebPage.h"
#include "WebPageManager.h"
#include "NetworkCookieJar.h"
#include <QNetworkCookie>

ClearCookies::ClearCookies(WebPageManager *manager, QStringList &arguments, QObject *parent) : Command(manager, arguments, parent) {}

void ClearCookies::start()
{
  NetworkCookieJar *jar = qobject_cast<NetworkCookieJar*>(page()
                                                          ->networkAccessManager()
                                                          ->cookieJar());
  jar->clearCookies();
  emit finished(new Response(true));
}
