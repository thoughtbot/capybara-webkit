#include "WebPage.h"
#include <QResource>

WebPage::WebPage(QObject *parent) : QWebPage(parent) {
  connect(mainFrame(), SIGNAL(javaScriptWindowObjectCleared()),
          this,        SLOT(injectJavascriptHelpers()));
  QResource javascript(":/capybara.js");
  m_capybaraJavascript = QString((const char *) javascript.data());
}

void WebPage::injectJavascriptHelpers() {
  mainFrame()->evaluateJavaScript(m_capybaraJavascript);
}

bool WebPage::shouldInterruptJavaScript() {
  return false;
}

