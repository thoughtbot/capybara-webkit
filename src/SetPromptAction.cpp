#include "SetPromptAction.h"
#include "WebPage.h"
#include "WebPageManager.h"

SetPromptAction::SetPromptAction(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {}

void SetPromptAction::start()
{
  page()->setPromptAction(arguments()[0]);
  finish(true);
}
