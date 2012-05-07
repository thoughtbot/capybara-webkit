#include "SetConfirmAction.h"
#include "WebPage.h"

SetConfirmAction::SetConfirmAction(WebPage *page, QStringList &arguments, QObject *parent) : Command(page, arguments, parent) {}

void SetConfirmAction::start()
{
  page()->setConfirmAction(arguments()[0]);
  emit finished(new Response(true));
}
