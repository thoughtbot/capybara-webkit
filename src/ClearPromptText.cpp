#include "ClearPromptText.h"
#include "WebPage.h"

ClearPromptText::ClearPromptText(WebPage *page, QStringList &arguments, QObject *parent) : Command(page, arguments, parent) {}

void ClearPromptText::start()
{
  page()->setPromptText(QString());
  emit finished(new Response(true));
}
