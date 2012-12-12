#include "JavascriptPromptMessages.h"
#include "WebPage.h"
#include "WebPageManager.h"

JavascriptPromptMessages::JavascriptPromptMessages(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {}

void JavascriptPromptMessages::start()
{
  emitFinished(true, page()->promptMessages());
}
