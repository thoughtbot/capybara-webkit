#include "AlertMessages.h"
#include "WebPage.h"

AlertMessages::AlertMessages(WebPage *page, QStringList &arguments, QObject *parent) : Command(page, arguments, parent) {}

void AlertMessages::start()
{
  emit finished(new Response(true, page()->alertMessages()));
}
