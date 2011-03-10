#include "Show.h"
#include "WebPage.h"

Show::Show(WebPage *page, QObject *parent) : Command(page, parent) {
}

void Show::start(QStringList &arguments) {
  Q_UNUSED(arguments);
  page()->showInWindow();
  QString response;
  emit finished(true, response);
}

