#include "JavascriptAlertMessages.h"
#include "WebPage.h"
#include "WebPageManager.h"

JavascriptAlertMessages::JavascriptAlertMessages(WebPageManager *manager, QStringList &arguments, QObject *parent) : Command(manager, arguments, parent) {}

void JavascriptAlertMessages::start()
{
  emit finished(new Response(true, page()->alertMessages()));
}
