#include "SetConfirmAction.h"
#include "WebPage.h"
#include "WebPageManager.h"

SetConfirmAction::SetConfirmAction(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {}

void SetConfirmAction::start()
{
  page()->setConfirmAction(arguments()[0]);
  finish(true);
}
