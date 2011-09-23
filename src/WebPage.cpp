#include "WebPage.h"
#include "JavascriptInvocation.h"
#include "NetworkAccessManager.h"
#include "UnsupportedContentHandler.h"
#include <QResource>
#include <iostream>

WebPage::WebPage(QObject *parent) : QWebPage(parent) {
  setForwardUnsupportedContent(true);
  loadJavascript();
  setUserStylesheet();

  m_loading = false;
  this->setCustomNetworkAccessManager();

  connect(this, SIGNAL(loadStarted()), this, SLOT(loadStarted()));
  connect(this, SIGNAL(loadFinished(bool)), this, SLOT(loadFinished(bool)));
  connect(this, SIGNAL(frameCreated(QWebFrame *)),
          this, SLOT(frameCreated(QWebFrame *)));
  connect(this, SIGNAL(unsupportedContent(QNetworkReply*)),
      this, SLOT(handleUnsupportedContent(QNetworkReply*)));
}

void WebPage::setCustomNetworkAccessManager() {
  NetworkAccessManager *manager = new NetworkAccessManager();
  this->setNetworkAccessManager(manager);
  connect(manager, SIGNAL(finished(QNetworkReply *)), this, SLOT(replyFinished(QNetworkReply *)));
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
  m_loading = false;
  emit pageFinished(success);
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

QString WebPage::chooseFile(QWebFrame *parentFrame, const QString &suggestedFile) {
  Q_UNUSED(parentFrame);
  Q_UNUSED(suggestedFile);

  return getLastAttachedFileName();
}

bool WebPage::extension(Extension extension, const ExtensionOption *option, ExtensionReturn *output) {
  Q_UNUSED(option);
  if (extension == ChooseMultipleFilesExtension) {
    QStringList names = QStringList() << getLastAttachedFileName();
    static_cast<ChooseMultipleFilesExtensionReturn*>(output)->fileNames = names;
    return true;
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

int WebPage::getLastStatus() {
  return m_lastStatus;
}

void WebPage::resetResponseHeaders() {
  m_lastStatus = 0;
  m_pageHeaders = QString();
}

QString WebPage::pageHeaders() {
  return m_pageHeaders;
}

void WebPage::handleUnsupportedContent(QNetworkReply *reply) {
  UnsupportedContentHandler *handler = new UnsupportedContentHandler(this, reply);
  Q_UNUSED(handler);
}
