#include "FrameFocus.h"
#include "Command.h"
#include "WebPage.h"

FrameFocus::FrameFocus(WebPage *page, QObject *parent) : Command(page, parent) {
}

void FrameFocus::start(QStringList &arguments) {
  QString response;
  emit finished(true, response);
}

