#include "GetCookies.h"
#include "WebPage.h"
#include "WebPageManager.h"
#include "NetworkCookieJar.h"

GetCookies::GetCookies(WebPageManager *manager, QStringList &arguments, QObject *parent) : Command(manager, arguments, parent)
{
  m_buffer = "";
}

void GetCookies::start()
{
  NetworkCookieJar *jar = manager()->cookieJar();
  foreach (QNetworkCookie cookie, jar->getAllCookies()) {
    m_buffer.append(cookie.toRawForm());
    m_buffer.append("\n");
  }
  emit finished(new Response(true, m_buffer));
}
