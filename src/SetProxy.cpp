#include "SetProxy.h"
#include "WebPage.h"
#include <QNetworkAccessManager>
#include <QNetworkProxy>

SetProxy::SetProxy(WebPage *page, QStringList &arguments, QObject *parent) : Command(page, arguments, parent) {}

void SetProxy::start()
{
  // default to empty proxy
  QNetworkProxy proxy;

  if (arguments().size() > 0)
    proxy = QNetworkProxy(QNetworkProxy::HttpProxy,
                          arguments()[0],
                          (quint16)(arguments()[1].toInt()),
                          arguments()[2],
                          arguments()[3]);

  page()->networkAccessManager()->setProxy(proxy);
  emit finished(new Response(true));
}
