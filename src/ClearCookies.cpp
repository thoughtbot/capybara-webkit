#include "ClearCookies.h"
#include "WebPage.h"
#include "NetworkCookieJar.h"
#include <QNetworkCookie>

ClearCookies::ClearCookies(WebPage *page, QObject *parent)
  : Command(page, parent)
{ }

void ClearCookies::start(QStringList &arguments)
{
  Q_UNUSED(arguments);
  NetworkCookieJar *jar = qobject_cast<NetworkCookieJar*>(page()
                                                          ->networkAccessManager()
                                                          ->cookieJar());
  jar->clearCookies();
  emit finished(new Response(true));
}
