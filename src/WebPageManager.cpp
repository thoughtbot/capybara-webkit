#include "WebPageManager.h"
#include "WebPage.h"
#include <stdio.h>

WebPageManager::WebPageManager() {
}

void WebPageManager::append(WebPage *value) {
  m_pages.append(value);
}

QListIterator<WebPage *> WebPageManager::iterator() {
  return QListIterator<WebPage *>(m_pages);
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
