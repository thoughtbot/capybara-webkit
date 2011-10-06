#include "SetHtml.h"
#include "WebPage.h"
#include <QUrl>

SetHtml::SetHtml(WebPage *page, QObject *parent)
  : Command(page, parent)
{ }

void SetHtml::start(QStringList &arguments) {
  if (arguments.size() > 1)
    page()->currentFrame()->setHtml(arguments[0], QUrl(arguments[1]));
  else
    page()->currentFrame()->setHtml(arguments[0]);
  emit finished(new Response(true));
}

void SetHtml::loadFinished(bool success) {
  QString message;
  if (!success)
    message = page()->failureString();

  disconnect(page(), SIGNAL(pageFinished(bool)), this,
             SLOT(loadFinished(bool)));
  emit finished(new Response(success, message));
}
