#include "SetProxy.h"
#include "WebPage.h"
#include "WebPageManager.h"
#include "NetworkAccessManager.h"
#include <QNetworkProxy>

SetProxy::SetProxy(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {}

void SetProxy::start()
{
  // default to empty proxy
  QNetworkProxy proxy;

  if (arguments().size() > 0) {
    proxy.setType(arguments()[4] == 'socks' ? QNetworkProxy::Socks5Proxy : QNetworkProxy::HttpProxy);
    proxy.setHostName(arguments()[0]);
    proxy.setPort((quint16)(arguments()[1].toInt()));
    proxy.setUser(arguments()[2]);
    proxy.setPassword(arguments()[3]);
  }

  manager()->networkAccessManager()->setProxy(proxy);
  finish(true);
}
