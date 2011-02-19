#include "Visit.h"
#include "Command.h"
#include "WebPage.h"
#include <iostream>

Visit::Visit(WebPage *page, QObject *parent) : Command(page, parent) {
  connect(page, SIGNAL(loadFinished(bool)), this, SLOT(loadFinished(bool)));
}

void Visit::receivedArgument(const char *url) {
  std::cout << ">> Loading page: " << url << std::endl;
  page()->mainFrame()->setUrl(QUrl(url));
}

void Visit::loadFinished(bool success) {
  std::cout << ">> Page loaded" << std::endl;
  QString response;
  std::cout << page()->mainFrame()->toHtml().toAscii().constData() << std::endl;
  emit finished(success, response);
}

