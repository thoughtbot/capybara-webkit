#include "WebPageManager.h"

WebPageManager *WebPageManager::m_instance = NULL;

WebPageManager::WebPageManager() {
}

WebPageManager *WebPageManager::getInstance() {
  if(!m_instance)
    m_instance = new WebPageManager();

  return m_instance;
}

void WebPageManager::append(WebPage *value) {
  m_pages.append(value);
}

QListIterator<WebPage *> WebPageManager::iterator() {
  return QListIterator<WebPage *>(m_pages);
}

