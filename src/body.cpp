#include "Body.h"
#include "WebPage.h"

Body::Body(WebPage *page, QStringList &arguments, QObject *parent) : Command(page, arguments, parent) {
}

void Body::start() {
  QString result = page()->currentFrame()->toHtml();
  emit finished(new Response(true, result));
}
