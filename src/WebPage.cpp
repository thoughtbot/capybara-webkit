#include "WebPage.h"
#include "JavascriptInvocation.h"
#include <QResource>
#include <iostream>

WebPage::WebPage(QObject *parent) : QWebPage(parent) {
  connect(mainFrame(), SIGNAL(javaScriptWindowObjectCleared()),
          this,        SLOT(injectJavascriptHelpers()));
  QResource javascript(":/capybara.js");
  char * javascriptString =  new char[javascript.size() + 1];
  strcpy(javascriptString, (const char *)javascript.data());
  javascriptString[javascript.size()] = 0;
  m_capybaraJavascript = javascriptString;
  delete javascriptString;
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

void WebPage::javaScriptConsoleMessage(const QString &message, int lineNumber, const QString &sourceID) {
  if (!sourceID.isEmpty())
    std::cout << qPrintable(sourceID) << ":" << lineNumber << " ";
  std::cout << qPrintable(message) << std::endl;
}

