#include "JavascriptDialogMessages.h"
#include "WebPage.h"

JavascriptDialogMessages::JavascriptDialogMessages(WebPage *page, QStringList &arguments, QObject *parent) : Command(page, arguments, parent) {}

void JavascriptDialogMessages::start()
{
  QString option = arguments()[0];
  if (option.compare("Alert") == 0)
    emit finished(new Response(true, page()->alertMessages()));
  else if (option.compare("Confirm") == 0)
    emit finished(new Response(true, page()->confirmMessages()));
  else if (option.compare("Prompt") == 0)
    emit finished(new Response(true, page()->promptMessages()));
  else
    emit finished(new Response(true, QString("")));
}
