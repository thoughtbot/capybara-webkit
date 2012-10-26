#include "WebPageManager.h"
#include "WebPage.h"
#include "NetworkCookieJar.h"

WebPageManager::WebPageManager(QObject *parent) : QObject(parent) {
  m_ignoreSslErrors = false;
  m_cookieJar = new NetworkCookieJar(this);
  m_success = true;
  m_loggingEnabled = false;
  m_ignoredOutput = new QString();
  m_timeout = -1;
  createPage(this)->setFocus();
}

void WebPageManager::append(WebPage *value) {
  m_pages.append(value);
}

QList<WebPage *> WebPageManager::pages() const {
  return m_pages;
}

void WebPageManager::setCurrentPage(WebPage *page) {
  m_currentPage = page;
}

WebPage *WebPageManager::currentPage() const {
  return m_currentPage;
}

WebPage *WebPageManager::createPage(QObject *parent) {
  WebPage *page = new WebPage(this, parent);
  connect(page, SIGNAL(loadStarted()),
          this, SLOT(emitLoadStarted()));
  connect(page, SIGNAL(pageFinished(bool)),
          this, SLOT(setPageStatus(bool)));
  connect(page, SIGNAL(requestCreated(QByteArray &, QNetworkReply *)),
          this, SLOT(requestCreated(QByteArray &, QNetworkReply *)));
  connect(page, SIGNAL(replyFinished(QNetworkReply *)),
          this, SLOT(replyFinished(QNetworkReply *)));
  append(page);
  return page;
}

void WebPageManager::emitLoadStarted() {
  if (m_started.empty()) {
    logger() << "Load started";
    emit loadStarted();
  }
}

void WebPageManager::requestCreated(QByteArray &url, QNetworkReply *reply) {
  logger() << "Started request to" << url;
  m_started += reply;
}

void WebPageManager::replyFinished(QNetworkReply *reply) {
  int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
  logger() << "Received" << status << "from" << reply->url().toString();
  m_started.remove(reply);
  logger() << m_started.size() << "requests remaining";
  if (m_started.empty() && !m_success) {
    emitPageFinished();
  }
}

void WebPageManager::setPageStatus(bool success) {
  logger() << "Page finished with" << success;
  m_success = success && m_success;
  if (m_started.empty()) {
    emitPageFinished();
  }
}

void WebPageManager::emitPageFinished() {
  logger() << "Load finished";
  emit pageFinished(m_success);
  m_success = true;
}

void WebPageManager::setIgnoreSslErrors(bool value) {
  m_ignoreSslErrors = value;
}

bool WebPageManager::ignoreSslErrors() {
  return m_ignoreSslErrors;
}

int WebPageManager::getTimeout() {
  return m_timeout;
}

void WebPageManager::setTimeout(int timeout) {
  m_timeout = timeout;
}

void WebPageManager::reset() {
  m_timeout = -1;
  m_cookieJar->clearCookies();
  m_pages.first()->deleteLater();
  m_pages.clear();
  createPage(this)->setFocus();
}

NetworkCookieJar *WebPageManager::cookieJar() {
  return m_cookieJar;
}

bool WebPageManager::isLoading() const {
  foreach(WebPage *page, pages()) {
    if (page->isLoading()) {
      return true;
    }
  }
  return false;
}

QDebug WebPageManager::logger() const {
  if (m_loggingEnabled)
    return qDebug();
  else
    return QDebug(m_ignoredOutput);
}

void WebPageManager::enableLogging() {
  m_loggingEnabled = true;
}
