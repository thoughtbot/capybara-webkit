#include "GetCookies.h"
#include "WebPage.h"
#include "NetworkCookieJar.h"

GetCookies::GetCookies(WebPage *page, QStringList &arguments, QObject *parent) : Command(page, arguments, parent)
{
  m_buffer = "";
}

void GetCookies::start()
{
  NetworkCookieJar *jar = qobject_cast<NetworkCookieJar*>(page()
                                                          ->networkAccessManager()
                                                          ->cookieJar());
  foreach (QNetworkCookie cookie, jar->getAllCookies()) {
    m_buffer.append(cookie.toRawForm());
    m_buffer.append("\n");
  }
  emit finished(new Response(true, m_buffer));
}
