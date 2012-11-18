#include "Body.h"
#include "WebPage.h"
#include "WebPageManager.h"

Body::Body(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
}

void Body::start() {
  QString result;
  if (page()->contentType().contains("html"))
    result = page()->currentFrame()->toHtml();
  else
    result = page()->body();

  finish(true, result);
}
