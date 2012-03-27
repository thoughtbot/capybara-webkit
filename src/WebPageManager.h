#ifndef _WEBPAGEMANAGER_H
#define _WEBPAGEMANAGER_H
#include "WebPage.h"
#include <QList>

class WebPageManager {
  public:
    static WebPageManager *getInstance();
    void append(WebPage *value);
    QListIterator<WebPage *> iterator();

  private:
    WebPageManager();
    QList<WebPage *> m_pages;
    static WebPageManager *m_instance;
};

#endif // _WEBPAGEMANAGER_H

