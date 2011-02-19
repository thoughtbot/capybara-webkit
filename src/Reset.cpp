#include "Reset.h"
#include "WebPage.h"

Reset::Reset(WebPage *page, QObject *parent) : Command(page, parent) {
}

void Reset::start() {
  page()->triggerAction(QWebPage::Stop);
  page()->mainFrame()->setHtml("<html><body></body></html>");
  QString response = "";
  emit finished(true, response);
}

