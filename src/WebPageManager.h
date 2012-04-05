#ifndef _WEBPAGEMANAGER_H
#define _WEBPAGEMANAGER_H
#include <QList>
#include <QObject>

class WebPage;

class WebPageManager : public QObject {
  Q_OBJECT

  public:
    WebPageManager(QObject *parent = 0);
    void append(WebPage *value);
    QList<WebPage *> pages();
    void setCurrentPage(WebPage *);
    WebPage *currentPage();
    WebPage *createPage(QObject *parent);
    void setIgnoreSslErrors(bool);
    bool ignoreSslErrors();

  public slots:
    void emitPageFinished(bool);

  signals:
    void pageFinished(bool);

  private:
    QList<WebPage *> m_pages;
    WebPage *m_currentPage;
    bool m_ignoreSslErrors;
};

#endif // _WEBPAGEMANAGER_H

