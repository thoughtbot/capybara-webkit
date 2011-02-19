#include "WebPage.h"

WebPage::WebPage(QObject *parent) : QWebPage(parent) {
}

bool WebPage::shouldInterruptJavaScript() {
  return false;
}

