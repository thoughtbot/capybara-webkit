#include "SetProxy.h"
#include "WebPage.h"
#include <QNetworkAccessManager>
#include <QNetworkProxy>

SetProxy::SetProxy(WebPage *page, QObject *parent)
  : Command(page, parent)
{ }

void SetProxy::start(QStringList &arguments)
{
  // default to empty proxy
  QNetworkProxy proxy;

  if (arguments.size() > 0)
    proxy = QNetworkProxy(QNetworkProxy::HttpProxy,
                          arguments[0],
                          (quint16)(arguments[1].toInt()),
                          arguments[2],
                          arguments[3]);

  page()->networkAccessManager()->setProxy(proxy);
  emit finished(new Response(true));
}
