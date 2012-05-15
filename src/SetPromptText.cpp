#include "SetPromptText.h"
#include "WebPage.h"

SetPromptText::SetPromptText(WebPage *page, QStringList &arguments, QObject *parent) : Command(page, arguments, parent) {}

void SetPromptText::start()
{
  page()->setPromptText(arguments()[0]);
  emit finished(new Response(true));
}
