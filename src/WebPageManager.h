#ifndef _WEBPAGEMANAGER_H
#define _WEBPAGEMANAGER_H
#include <QList>
#include <QObject>

class WebPage;

class WebPageManager {
  public:
    WebPageManager();
    void append(WebPage *value);
    QListIterator<WebPage *> iterator();
    void setCurrentPage(WebPage *);
    WebPage *currentPage();
    WebPage *createPage(QObject *);

  private:
    QList<WebPage *> m_pages;
    WebPage *m_currentPage;
};

#endif // _WEBPAGEMANAGER_H

