#ifndef __NETWORKACCESSMANAGER_H
#define __NETWORKACCESSMANAGER_H
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <QStringList>

class NetworkAccessManager : public QNetworkAccessManager {

  Q_OBJECT

  public:
    NetworkAccessManager(QObject *parent = 0);
    void addHeader(QString key, QString value);
    void reset();
    void setUserName(const QString &userName);
    void setPassword(const QString &password);
    void setUrlBlacklist(QStringList urlBlacklist);

  protected:
    QNetworkReply* createRequest(QNetworkAccessManager::Operation op, const QNetworkRequest &req, QIODevice * outgoingData);
    QString m_userName;
    QString m_password;
    QList<QUrl> m_urlBlacklist;

  private:
    void disableKeyChainLookup();

    QHash<QString, QString> m_headers;
    bool isBlacklisted(QUrl url);
    QHash<QUrl, QUrl> m_redirectMappings;

  private slots:
    void provideAuthentication(QNetworkReply *reply, QAuthenticator *authenticator);
    void finished(QNetworkReply *);

  signals:
    void requestCreated(QByteArray &url, QNetworkReply *reply);
    void finished(QUrl &, QNetworkReply *);
};
#endif
