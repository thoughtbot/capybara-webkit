#include "JavascriptConfirmMessages.h"
#include "WebPage.h"

JavascriptConfirmMessages::JavascriptConfirmMessages(WebPage *page, QStringList &arguments, QObject *parent) : Command(page, arguments, parent) {}

void JavascriptConfirmMessages::start()
{
  emit finished(new Response(true, page()->confirmMessages()));
}
