#include "SetProxy.h"
#include "WebPage.h"
#include "WebPageManager.h"
#include <QNetworkAccessManager>
#include <QNetworkProxy>

SetProxy::SetProxy(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {}

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
