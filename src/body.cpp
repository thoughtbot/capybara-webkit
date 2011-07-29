#include "Body.h"
#include "WebPage.h"

Body::Body(WebPage *page, QObject *parent) : Command(page, parent) {
}

void Body::start(QStringList &arguments) {
  Q_UNUSED(arguments);
  QString result = page()->currentFrame()->toHtml();
  emit finished(new Response(true, result));
}
