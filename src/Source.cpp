#include "Source.h"
#include "WebPage.h"

Source::Source(WebPage *page, QObject *parent) : Command(page, parent) {
}

void Source::start(QStringList &arguments) {
  Q_UNUSED(arguments)

  QString result = page()->currentFrame()->toHtml();
  emit finished(new Response(true, result));
}

