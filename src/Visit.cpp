#include "Visit.h"
#include "Command.h"
#include "WebPage.h"
#include <iostream>

Visit::Visit(WebPage *page, QObject *parent) : Command(page, parent) {
  connect(page, SIGNAL(loadFinished(bool)), this, SLOT(loadFinished(bool)));
}

void Visit::receivedArgument(const char *url) {
  page()->mainFrame()->setUrl(QUrl(url));
}

void Visit::loadFinished(bool success) {
  QString response;
  emit finished(success, response);
}

