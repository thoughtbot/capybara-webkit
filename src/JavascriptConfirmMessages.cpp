#include "JavascriptConfirmMessages.h"
#include "WebPage.h"
#include "WebPageManager.h"

JavascriptConfirmMessages::JavascriptConfirmMessages(WebPageManager *manager, QStringList &arguments, QObject *parent) : Command(manager, arguments, parent) {}

void JavascriptConfirmMessages::start()
{
  emit finished(new Response(true, page()->confirmMessages()));
}
