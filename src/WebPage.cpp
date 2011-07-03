#include "WebPage.h"
#include "JavascriptInvocation.h"
#include "NetworkAccessManager.h"
#include <QResource>
#include <iostream>

WebPage::WebPage(QObject *parent) : QWebPage(parent) {
  QResource javascript(":/capybara.js");
  if (javascript.isCompressed()) {
    QByteArray uncompressedBytes(qUncompress(javascript.data(), javascript.size()));
    m_capybaraJavascript = QString(uncompressedBytes);
  } else {
    char * javascriptString =  new char[javascript.size() + 1];
    strcpy(javascriptString, (const char *)javascript.data());
    javascriptString[javascript.size()] = 0;
    m_capybaraJavascript = javascriptString;
  }
  m_loading = false;

  this->setNetworkAccessManager(new NetworkAccessManager());

  connect(this, SIGNAL(loadStarted()), this, SLOT(loadStarted()));
  connect(this, SIGNAL(loadFinished(bool)), this, SLOT(loadFinished(bool)));
  connect(this, SIGNAL(frameCreated(QWebFrame *)),
          this, SLOT(frameCreated(QWebFrame *)));
}

QString WebPage::userAgentForUrl(const QUrl &url ) const {
  if (!m_userAgent.isEmpty()) {
    return m_userAgent;
  } else {
    return QWebPage::userAgentForUrl(url);
  }
}

void WebPage::setUserAgent(QString userAgent) {
  m_userAgent = userAgent;
}

void WebPage::frameCreated(QWebFrame * frame) {
  connect(frame, SIGNAL(javaScriptWindowObjectCleared()),
          this,  SLOT(injectJavascriptHelpers()));
}

void WebPage::injectJavascriptHelpers() {
  QWebFrame* frame = qobject_cast<QWebFrame *>(QObject::sender());
  frame->evaluateJavaScript(m_capybaraJavascript);
}

bool WebPage::shouldInterruptJavaScript() {
  return false;
}

QVariant WebPage::invokeCapybaraFunction(const char *name, QStringList &arguments) {
  QString qname(name);
  QString objectName("CapybaraInvocation");
  JavascriptInvocation invocation(qname, arguments);
  currentFrame()->addToJavaScriptWindowObject(objectName, &invocation);
  QString javascript = QString("Capybara.invoke()");
  return currentFrame()->evaluateJavaScript(javascript);
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
  return QString("Unable to load URL: ") + currentFrame()->requestedUrl().toString();
}

bool WebPage::render(const QString &fileName) {
  QFileInfo fileInfo(fileName);
  QDir dir;
  dir.mkpath(fileInfo.absolutePath());

  QSize viewportSize = this->viewportSize();
  QSize pageSize = this->mainFrame()->contentsSize();
  if (pageSize.isEmpty()) {
    return false;
  }

  QImage buffer(pageSize, QImage::Format_ARGB32);
  buffer.fill(qRgba(255, 255, 255, 0));

  QPainter p(&buffer);
  p.setRenderHint( QPainter::Antialiasing,          true);
  p.setRenderHint( QPainter::TextAntialiasing,      true);
  p.setRenderHint( QPainter::SmoothPixmapTransform, true);

  this->setViewportSize(pageSize);
  this->mainFrame()->render(&p);
  p.end();
  this->setViewportSize(viewportSize);

  return buffer.save(fileName);
}
