#include "Body.h"
#include "WebPage.h"
#include "WebPageManager.h"

Body::Body(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
}

void Body::start() {
  QString result;
  if (page()->unsupportedContentLoaded())
    result = page()->currentFrame()->toPlainText();
  else
    result = page()->currentFrame()->toHtml();

  emitFinished(true, result);
}
