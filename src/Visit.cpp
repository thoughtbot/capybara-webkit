#include "Visit.h"
#include "Command.h"
#include "WebPage.h"

Visit::Visit(WebPage *page, QObject *parent) : Command(page, parent) {
  connect(page, SIGNAL(loadFinished(bool)), this, SLOT(loadFinished(bool)));
}

void Visit::start(QStringList &arguments) {
  page()->mainFrame()->setUrl(QUrl(arguments[0]));
}

void Visit::loadFinished(bool success) {
  QString response;
  emit finished(success, response);
}

