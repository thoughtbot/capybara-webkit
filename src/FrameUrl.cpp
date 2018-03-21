#include "FrameUrl.h"
#include "SocketCommand.h"
#include "WebPage.h"
#include "WebPageManager.h"

FrameUrl::FrameUrl(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
}

void FrameUrl::start() {
  QVariant result = page()->currentFrame()->evaluateJavaScript("window.location.toString()");
  QString url = result.toString();
  finish(true, url);
}
