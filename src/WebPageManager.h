#ifndef _WEBPAGEMANAGER_H
#define _WEBPAGEMANAGER_H
#include <QList>
#include <QSet>
#include <QObject>
#include <QNetworkReply>

class WebPage;
class NetworkCookieJar;

class WebPageManager : public QObject {
  Q_OBJECT

  public:
    WebPageManager(QObject *parent = 0);
    void append(WebPage *value);
    QList<WebPage *> pages() const;
    void setCurrentPage(WebPage *);
    WebPage *currentPage();
    WebPage *createPage(QObject *parent);
    void setIgnoreSslErrors(bool);
    bool ignoreSslErrors();
    void reset();
    NetworkCookieJar *cookieJar();
    bool isLoading() const;

  public slots:
    void emitLoadStarted();
    void emitPageFinished(bool);
    void requestCreated(QNetworkReply *reply);
    void replyFinished(QNetworkReply *reply);

  signals:
    void pageFinished(bool);
    void loadStarted();

  private:
    QList<WebPage *> m_pages;
    WebPage *m_currentPage;
    bool m_ignoreSslErrors;
    NetworkCookieJar *m_cookieJar;
    QSet<QNetworkReply*> m_started;
    bool m_success;
};

#endif // _WEBPAGEMANAGER_H

