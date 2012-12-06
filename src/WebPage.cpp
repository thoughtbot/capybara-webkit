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
  m_failed = false;
  m_manager = manager;
  m_uuid = QUuid::createUuid().toString();
  m_unsupportedContentLoaded = false;

  setForwardUnsupportedContent(true);
  loadJavascript();
  setUserStylesheet();

  m_confirm = true;
  m_prompt = false;
  m_prompt_text = QString();
  this->setCustomNetworkAccessManager();

  connect(this, SIGNAL(loadStarted()), this, SLOT(loadStarted()));
  connect(this, SIGNAL(loadFinished(bool)), this, SLOT(loadFinished(bool)));
  connect(this, SIGNAL(frameCreated(QWebFrame *)),
          this, SLOT(frameCreated(QWebFrame *)));
  connect(this, SIGNAL(unsupportedContent(QNetworkReply*)),
      this, SLOT(handleUnsupportedContent(QNetworkReply*)));
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
  connect(manager, SIGNAL(sslErrors(QNetworkReply *, QList<QSslError>)),
          this, SLOT(handleSslErrorsForReply(QNetworkReply *, QList<QSslError>)));
  connect(manager, SIGNAL(requestCreated(QByteArray &, QNetworkReply *)),
          SIGNAL(requestCreated(QByteArray &, QNetworkReply *)));
}

void WebPage::unsupportedContentFinishedReply(QNetworkReply *reply) {
  m_unsupportedContentLoaded = true;
  m_manager->replyFinished(reply);
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

QString WebPage::alertMessages() {
  return m_alertMessages.join("\n");
}

QString WebPage::confirmMessages() {
  return m_confirmMessages.join("\n");
}

QString WebPage::promptMessages() {
  return m_promptMessages.join("\n");
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

QVariant WebPage::invokeCapybaraFunction(const char *name, const QStringList &arguments) {
  QString qname(name);
  QString objectName("CapybaraInvocation");
  JavascriptInvocation invocation(qname, arguments);
  currentFrame()->addToJavaScriptWindowObject(objectName, &invocation);
  QString javascript = QString("Capybara.invoke()");
  return currentFrame()->evaluateJavaScript(javascript);
}

QVariant WebPage::invokeCapybaraFunction(QString &name, const QStringList &arguments) {
  return invokeCapybaraFunction(name.toAscii().data(), arguments);
}

void WebPage::javaScriptConsoleMessage(const QString &message, int lineNumber, const QString &sourceID) {
  QString fullMessage = QString(message);
  if (!sourceID.isEmpty())
    fullMessage = sourceID + "|" + QString::number(lineNumber) + "|" + fullMessage;
  m_consoleMessages.append(fullMessage.replace("\n", "\\n"));
  m_manager->logger() << qPrintable(fullMessage);
}

void WebPage::javaScriptAlert(QWebFrame *frame, const QString &message) {
  Q_UNUSED(frame);
  m_alertMessages.append(message);
  m_manager->logger() << "ALERT:" << qPrintable(message);
}

bool WebPage::javaScriptConfirm(QWebFrame *frame, const QString &message) {
  Q_UNUSED(frame);
  m_confirmMessages.append(message);
  return m_confirm;
}

bool WebPage::javaScriptPrompt(QWebFrame *frame, const QString &message, const QString &defaultValue, QString *result) {
  Q_UNUSED(frame)
  m_promptMessages.append(message);
  if (m_prompt) {
    if (m_prompt_text.isNull()) {
      *result = defaultValue;
    } else {
      *result = m_prompt_text;
    }
  }
  return m_prompt;
}

void WebPage::loadStarted() {
  m_loading = true;
  m_errorPageMessage = QString();
  m_unsupportedContentLoaded = false;
}

void WebPage::loadFinished(bool success) {
  Q_UNUSED(success);
  m_loading = false;
  emit pageFinished(!m_failed);
  m_failed = false;
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

  return getAttachedFileNames().first();
}

bool WebPage::extension(Extension extension, const ExtensionOption *option, ExtensionReturn *output) {
  if (extension == ChooseMultipleFilesExtension) {
    static_cast<ChooseMultipleFilesExtensionReturn*>(output)->fileNames = getAttachedFileNames();
    return true;
  }
  else if (extension == QWebPage::ErrorPageExtension) {
    ErrorPageExtensionOption *errorOption = (ErrorPageExtensionOption*) option;
    m_errorPageMessage = " because of error loading " + errorOption->url.toString() + ": " + errorOption->errorString;
    m_failed = true;
    return false;
  }
  return false;
}

QStringList WebPage::getAttachedFileNames() {
  return currentFrame()->evaluateJavaScript(QString("Capybara.attachedFiles")).toStringList();
}

void WebPage::handleSslErrorsForReply(QNetworkReply *reply, const QList<QSslError> &errors) {
  if (m_manager->ignoreSslErrors())
    reply->ignoreSslErrors(errors);
}

void WebPage::setSkipImageLoading(bool skip) {
  settings()->setAttribute(QWebSettings::AutoLoadImages, !skip);
}

int WebPage::getLastStatus() {
  return networkAccessManager()->statusFor(currentFrame()->requestedUrl());
}

const QList<QNetworkReply::RawHeaderPair> &WebPage::pageHeaders() {
  return networkAccessManager()->headersFor(currentFrame()->requestedUrl());
}

NetworkAccessManager *WebPage::networkAccessManager() {
  return qobject_cast<NetworkAccessManager *>(QWebPage::networkAccessManager());
}

void WebPage::handleUnsupportedContent(QNetworkReply *reply) {
  QVariant contentMimeType = reply->header(QNetworkRequest::ContentTypeHeader);
  if(!contentMimeType.isNull()) {
    triggerAction(QWebPage::Stop);
    UnsupportedContentHandler *handler = new UnsupportedContentHandler(this, reply);
    if (reply->isFinished())
      handler->renderNonHtmlContent();
    else
      handler->waitForReplyToFinish();
  }
}

bool WebPage::unsupportedContentLoaded() {
  return m_unsupportedContentLoaded;
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

void WebPage::setConfirmAction(QString action) {
  m_confirm = (action == "Yes");
}

void WebPage::setPromptAction(QString action) {
  m_prompt = (action == "Yes");
}

void WebPage::setPromptText(QString text) {
  m_prompt_text = text;
}

