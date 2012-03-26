#include "WebPageManager.h"

WebPageManager *WebPageManager::m_instance = NULL;

WebPageManager::WebPageManager() {
  webPages = new QList<WebPage*>();
}

WebPageManager *WebPageManager::getInstance() {
  if(!m_instance)
    m_instance = new WebPageManager();

  return m_instance;
}

void WebPageManager::append(WebPage *value) {
  webPages->append(value);
}

WebPage *WebPageManager::last() {
  return (WebPage*) webPages->last();
}

