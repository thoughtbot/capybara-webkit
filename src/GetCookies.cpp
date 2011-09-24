#include "GetCookies.h"
#include "WebPage.h"
#include "NetworkCookieJar.h"

GetCookies::GetCookies(WebPage *page, QObject *parent)
  : Command(page, parent)
{
  m_buffer = "";
}

void GetCookies::start(QStringList &arguments)
{
  Q_UNUSED(arguments);
  NetworkCookieJar *jar = qobject_cast<NetworkCookieJar*>(page()
                                                          ->networkAccessManager()
                                                          ->cookieJar());
  foreach (QNetworkCookie cookie, jar->getAllCookies()) {
    m_buffer.append(cookie.toRawForm());
    m_buffer.append("\n");
  }
  emit finished(new Response(true, m_buffer));
}
