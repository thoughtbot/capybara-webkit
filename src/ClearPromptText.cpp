#include "ClearPromptText.h"
#include "WebPage.h"
#include "WebPageManager.h"

ClearPromptText::ClearPromptText(WebPageManager *manager, QStringList &arguments, QObject *parent) : Command(manager, arguments, parent) {}

void ClearPromptText::start()
{
  page()->setPromptText(QString());
  emit finished(new Response(true));
}
