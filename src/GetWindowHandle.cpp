#include "GetWindowHandle.h"
#include "WebPage.h"
#include <QStringList>

GetWindowHandle::GetWindowHandle(WebPage *page, QStringList &arguments, QObject *parent) : Command(page, arguments, parent) {
}

void GetWindowHandle::start() {
  emit finished(new Response(true, page()->uuid()));
}
