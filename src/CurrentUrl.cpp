#include "CurrentUrl.h"
#include "WebPage.h"
#include "WebPageManager.h"

CurrentUrl::CurrentUrl(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
}

void CurrentUrl::start() {
  QStringList arguments;
  QVariant result = page()->invokeCapybaraFunction("currentUrl", arguments);
  QString url = result.toString();
  emit finished(new Response(true, url));
}
