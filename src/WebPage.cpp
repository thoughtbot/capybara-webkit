#include "WebPage.h"
#include "JavascriptInvocation.h"
#include <QResource>
#include <QMainWindow>
#include <QApplication>
#include <iostream>

WebPage::WebPage(QObject *parent) : QWebPage(parent) {
  connect(mainFrame(), SIGNAL(javaScriptWindowObjectCleared()),
          this,        SLOT(injectJavascriptHelpers()));
  QResource javascript(":/capybara.js");
  char * javascriptString =  new char[javascript.size() + 1];
  strcpy(javascriptString, (const char *)javascript.data());
  javascriptString[javascript.size()] = 0;
  m_capybaraJavascript = javascriptString;
  m_loading = false;
  connect(this, SIGNAL(loadStarted()), this, SLOT(loadStarted()));
  connect(this, SIGNAL(loadFinished(bool)), this, SLOT(loadFinished(bool)));
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

void WebPage::javaScriptAlert(QWebFrame *frame, const QString &message) {
  Q_UNUSED(frame);
  std::cout << "ALERT: " << qPrintable(message) << std::endl;
}

bool WebPage::javaScriptConfirm(QWebFrame *frame, const QString &message) {
  Q_UNUSED(frame);
  Q_UNUSED(message);
  return true;
}

bool WebPage::javaScriptPrompt(QWebFrame *frame, const QString &message, const QString &defaultValue, QString *result) {
  Q_UNUSED(frame)
  Q_UNUSED(message)
  Q_UNUSED(defaultValue)
  Q_UNUSED(result)
  return false;
}

void WebPage::loadStarted() {
  m_loading = true;
}

void WebPage::loadFinished(bool success) {
  Q_UNUSED(success);
  m_loading = false;
}

bool WebPage::isLoading() const {
  return m_loading;
}

QString WebPage::failureString() {
  return QString("Unable to load URL: ") + mainFrame()->url().toString();
}

void WebPage::showInWindow() {
  m_window = new QMainWindow(0, Qt::WindowStaysOnTopHint);
  m_view = new QWebView(m_window);
  m_view->setPage(this);
  m_window->setCentralWidget(m_view);
  m_window->show();
}

