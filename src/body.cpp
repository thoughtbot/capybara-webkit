#include "Body.h"
#include "WebPage.h"
#include "WebPageManager.h"

Body::Body(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
}

void Body::start() {
  QString result = page()->currentFrame()->toHtml();
  emit finished(new Response(true, result));
}
