#include "WebPageManager.h"
#include "WebPage.h"
#include "NetworkCookieJar.h"
#include <stdio.h>

WebPageManager::WebPageManager(QObject *parent) : QObject(parent) {
  m_ignoreSslErrors = false;
  m_cookieJar = new NetworkCookieJar(this);
  m_success = true;
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

WebPage *WebPageManager::currentPage() {
  return m_currentPage;
}

WebPage *WebPageManager::createPage(QObject *parent) {
  WebPage *page = new WebPage(this, parent);
  connect(page, SIGNAL(loadStarted()),
          this, SLOT(emitLoadStarted()));
  connect(page, SIGNAL(pageFinished(bool)),
          this, SLOT(emitPageFinished(bool)));
  connect(page, SIGNAL(requestCreated(QNetworkReply *)),
          this, SLOT(requestCreated(QNetworkReply *)));
  connect(page, SIGNAL(replyFinished(QNetworkReply *)),
          this, SLOT(replyFinished(QNetworkReply *)));
  append(page);
  return page;
}

void WebPageManager::emitLoadStarted() {
  if (m_started.empty()) {
    emit loadStarted();
  }
}

void WebPageManager::requestCreated(QNetworkReply *reply) {
  m_started += reply;
}

void WebPageManager::replyFinished(QNetworkReply *reply) {
  m_started.remove(reply);
}

void WebPageManager::emitPageFinished(bool success) {
  m_success = success && m_success;
  if (m_started.empty()) {
    emit pageFinished(m_success);
    m_success = true;
  }
}

void WebPageManager::setIgnoreSslErrors(bool value) {
  m_ignoreSslErrors = value;
}

bool WebPageManager::ignoreSslErrors() {
  return m_ignoreSslErrors;
}

void WebPageManager::reset() {
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
