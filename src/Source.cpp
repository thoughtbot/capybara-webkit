#include "Source.h"
#include "WebPage.h"

Source::Source(WebPage *page, QObject *parent) : Command(page, parent) {
}

void Source::start(QStringList &arguments) {
  Q_UNUSED(arguments)

  QString response = page()->mainFrame()->toHtml();

  emit finished(true, response);
}

