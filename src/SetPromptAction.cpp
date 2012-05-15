#include "SetPromptAction.h"
#include "WebPage.h"

SetPromptAction::SetPromptAction(WebPage *page, QStringList &arguments, QObject *parent) : Command(page, arguments, parent) {}

void SetPromptAction::start()
{
  page()->setPromptAction(arguments()[0]);
  emit finished(new Response(true));
}
