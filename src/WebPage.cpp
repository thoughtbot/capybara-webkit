#include "WebPage.h"
#include "WebPageManager.h"
#include "JavascriptInvocation.h"
#include "NetworkAccessManager.h"
#include "NetworkCookieJar.h"
#include "UnsupportedContentHandler.h"
#include <QResource>
#include <iostream>
#include <QWebSettings>
#include <QUuid>

WebPage::WebPage(WebPageManager *manager, QObject *parent) : QWebPage(parent) {
  m_loading = false;
  m_manager = manager;
  m_uuid = QUuid::createUuid().toString();
  m_lastStatus = 0;

  setForwardUnsupportedContent(true);
  loadJavascript();
  setUserStylesheet();

  this->setCustomNetworkAccessManager();

  connect(this, SIGNAL(loadStarted()), this, SLOT(loadStarted()));
  connect(this, SIGNAL(loadFinished(bool)), this, SLOT(loadFinished(bool)));
  connect(this, SIGNAL(frameCreated(QWebFrame *)),
          this, SLOT(frameCreated(QWebFrame *)));
  connect(this, SIGNAL(unsupportedContent(QNetworkReply*)),
      this, SLOT(handleUnsupportedContent(QNetworkReply*)));
  connect(this, SIGNAL(pageFinished(bool)),
      m_manager, SLOT(emitPageFinished(bool)));
  connect(this, SIGNAL(loadStarted()),
      m_manager, SLOT(emitLoadStarted()));
  resetWindowSize();

  settings()->setAttribute(QWebSettings::JavascriptCanOpenWindows, true);
}

void WebPage::resetWindowSize() {
  this->setViewportSize(QSize(1680, 1050));
  this->settings()->setAttribute(QWebSettings::LocalStorageDatabaseEnabled, true);
}

void WebPage::setCustomNetworkAccessManager() {
  NetworkAccessManager *manager = new NetworkAccessManager(this);
  manager->setCookieJar(m_manager->cookieJar());
  this->setNetworkAccessManager(manager);
  connect(manager, SIGNAL(finished(QNetworkReply *)), this, SLOT(replyFinished(QNetworkReply *)));
  connect(manager, SIGNAL(sslErrors(QNetworkReply *, QList<QSslError>)),
          this, SLOT(handleSslErrorsForReply(QNetworkReply *, QList<QSslError>)));
}

void WebPage::loadJavascript() {
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
}

void WebPage::setUserStylesheet() {
  QString data = QString("* { font-family: 'Arial' ! important; }").toUtf8().toBase64();
  QUrl url = QUrl(QString("data:text/css;charset=utf-8;base64,") + data);
  settings()->setUserStyleSheetUrl(url);
}

QString WebPage::userAgentForUrl(const QUrl &url ) const {
  if (!m_userAgent.isEmpty()) {
    return m_userAgent;
  } else {
    return QWebPage::userAgentForUrl(url);
  }
}

QString WebPage::consoleMessages() {
  return m_consoleMessages.join("\n");
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
  QString fullMessage = QString::number(lineNumber) + "|" + message;
  if (!sourceID.isEmpty())
    fullMessage = sourceID + "|" + fullMessage;
  m_consoleMessages.append(fullMessage);
  std::cout << qPrintable(fullMessage) << std::endl;
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
  m_errorPageMessage = QString();
}

void WebPage::loadFinished(bool success) {
  m_loading = false;
  emit pageFinished(success);
}

bool WebPage::isLoading() const {
  return m_loading;
}

QString WebPage::failureString() {
  QString message = QString("Unable to load URL: ") + currentFrame()->requestedUrl().toString();
  if (m_errorPageMessage.isEmpty())
    return message;
  else
    return message + m_errorPageMessage;
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

QString WebPage::chooseFile(QWebFrame *parentFrame, const QString &suggestedFile) {
  Q_UNUSED(parentFrame);
  Q_UNUSED(suggestedFile);

  return getLastAttachedFileName();
}

bool WebPage::extension(Extension extension, const ExtensionOption *option, ExtensionReturn *output) {
  if (extension == ChooseMultipleFilesExtension) {
    QStringList names = QStringList() << getLastAttachedFileName();
    static_cast<ChooseMultipleFilesExtensionReturn*>(output)->fileNames = names;
    return true;
  }
  else if (extension == QWebPage::ErrorPageExtension) {
    ErrorPageExtensionOption *errorOption = (ErrorPageExtensionOption*) option;
    m_errorPageMessage = " because of error loading " + errorOption->url.toString() + ": " + errorOption->errorString;
    return false;
  }
  return false;
}

QString WebPage::getLastAttachedFileName() {
  return currentFrame()->evaluateJavaScript(QString("Capybara.lastAttachedFile")).toString();
}

void WebPage::replyFinished(QNetworkReply *reply) {
  if (reply->url() == this->currentFrame()->url()) {
    QStringList headers;
    m_lastStatus = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    QList<QByteArray> list = reply->rawHeaderList();

    int length = list.size();
    for(int i = 0; i < length; i++) {
      headers << list.at(i)+": "+reply->rawHeader(list.at(i));
    }

    m_pageHeaders = headers.join("\n");
  }
}

void WebPage::handleSslErrorsForReply(QNetworkReply *reply, const QList<QSslError> &errors) {
  if (m_manager->ignoreSslErrors())
    reply->ignoreSslErrors(errors);
}

void WebPage::setSkipImageLoading(bool skip) {
  settings()->setAttribute(QWebSettings::AutoLoadImages, !skip);
}

int WebPage::getLastStatus() {
  return m_lastStatus;
}

QString WebPage::pageHeaders() {
  return m_pageHeaders;
}

void WebPage::handleUnsupportedContent(QNetworkReply *reply) {
  UnsupportedContentHandler *handler = new UnsupportedContentHandler(this, reply);
  Q_UNUSED(handler);
}

bool WebPage::supportsExtension(Extension extension) const {
  if (extension == ErrorPageExtension)
    return true;
  else if (extension == ChooseMultipleFilesExtension)
    return true;
  else
    return false;
}

QWebPage *WebPage::createWindow(WebWindowType type) {
  Q_UNUSED(type);
  return m_manager->createPage(this);
}

QString WebPage::uuid() {
  return m_uuid;
}

QString WebPage::getWindowName() {
  QVariant windowName = mainFrame()->evaluateJavaScript("window.name");

  if (windowName.isValid())
    return windowName.toString();
  else
    return "";
}

bool WebPage::matchesWindowSelector(QString selector) {
  return (selector == getWindowName()           ||
      selector == mainFrame()->title()          ||
      selector == mainFrame()->url().toString() ||
      selector == uuid());
}

void WebPage::setFocus() {
  m_manager->setCurrentPage(this);
}
