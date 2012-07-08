#include "GetWindowHandles.h"
#include "WebPageManager.h"
#include "CommandFactory.h"
#include "WebPage.h"
#include <QStringList>

GetWindowHandles::GetWindowHandles(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
}

void GetWindowHandles::start() {
  QString handles = "[";
  QStringList stringList;

  foreach(WebPage *page, manager()->pages())
    stringList.append("\"" + page->uuid() + "\"");

  handles += stringList.join(",") + "]";

  emit finished(new Response(true, handles));
}
