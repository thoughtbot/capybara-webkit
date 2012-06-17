#include "JavascriptPromptMessages.h"
#include "WebPage.h"

JavascriptPromptMessages::JavascriptPromptMessages(WebPage *page, QStringList &arguments, QObject *parent) : Command(page, arguments, parent) {}

void JavascriptPromptMessages::start()
{
  emit finished(new Response(true, page()->promptMessages()));
}
