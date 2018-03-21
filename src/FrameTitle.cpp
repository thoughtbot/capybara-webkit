#include "FrameTitle.h"
#include "SocketCommand.h"
#include "WebPage.h"
#include "WebPageManager.h"

FrameTitle::FrameTitle(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
}

void FrameTitle::start() {
  finish(true, page()->currentFrame()->title());
}
