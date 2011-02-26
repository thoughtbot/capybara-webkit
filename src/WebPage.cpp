#include "WebPage.h"
#include "JavascriptInvocation.h"
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

QVariant WebPage::invokeCapybaraFunction(const char *name, QStringList &arguments) {
  QString qname(name);
  QString objectName("CapybaraInvocation");
  JavascriptInvocation invocation(qname, arguments);
  mainFrame()->addToJavaScriptWindowObject(objectName, &invocation);
  QString javascript = QString("Capybara.invoke()");
  return mainFrame()->evaluateJavaScript(javascript);
}

QVariant WebPage::invokeCapybaraFunction(QString &name, QStringList &arguments) {
  return invokeCapybaraFunction(name.toAscii().data(), arguments);
}

