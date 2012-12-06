#ifndef _WEBPAGEMANAGER_H
#define _WEBPAGEMANAGER_H
#include <QList>
#include <QSet>
#include <QObject>
#include <QNetworkReply>
#include <QDebug>
#include <QFile>

class WebPage;
class NetworkCookieJar;

class WebPageManager : public QObject {
  Q_OBJECT

  public:
    WebPageManager(QObject *parent = 0);
    void append(WebPage *value);
    QList<WebPage *> pages() const;
    void setCurrentPage(WebPage *);
    WebPage *currentPage() const;
    WebPage *createPage(QObject *parent);
    void setIgnoreSslErrors(bool);
    bool ignoreSslErrors();
    void setTimeout(int);
    int getTimeout();
    void reset();
    NetworkCookieJar *cookieJar();
    bool isLoading() const;
    QDebug logger() const;
    void enableLogging();
    void replyFinished(QNetworkReply *reply);

  public slots:
    void emitLoadStarted();
    void setPageStatus(bool);
    void requestCreated(QByteArray &url, QNetworkReply *reply);
    void handleReplyFinished();

  signals:
    void pageFinished(bool);
    void loadStarted();

  private:
    void emitPageFinished();
    static void handleDebugMessage(QtMsgType type, const char *message);

    QList<WebPage *> m_pages;
    WebPage *m_currentPage;
    bool m_ignoreSslErrors;
    NetworkCookieJar *m_cookieJar;
    QSet<WebPage *> m_started;
    bool m_success;
    bool m_loggingEnabled;
    QString *m_ignoredOutput;
    int m_timeout;
};

#endif // _WEBPAGEMANAGER_H

