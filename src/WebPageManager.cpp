#include "WebPageManager.h"
#include "WebPage.h"
#include "NetworkCookieJar.h"
#include <stdio.h>

WebPageManager::WebPageManager(QObject *parent) : QObject(parent) {
  m_ignoreSslErrors = false;
  m_cookieJar = new NetworkCookieJar(this);
  createPage(this)->setFocus();
}

void WebPageManager::append(WebPage *value) {
  m_pages.append(value);
}

QList<WebPage *> WebPageManager::pages() {
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
  append(page);
  return page;
}

void WebPageManager::emitPageFinished(bool success) {
  if (currentPage() == sender())
    emit pageFinished(success);
}

void WebPageManager::emitLoadStarted() {
  if (currentPage() == sender())
    emit loadStarted();
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
