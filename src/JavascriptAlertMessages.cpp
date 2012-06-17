#include "JavascriptAlertMessages.h"
#include "WebPage.h"

JavascriptAlertMessages::JavascriptAlertMessages(WebPage *page, QStringList &arguments, QObject *parent) : Command(page, arguments, parent) {}

void JavascriptAlertMessages::start()
{
  emit finished(new Response(true, page()->alertMessages()));
}
