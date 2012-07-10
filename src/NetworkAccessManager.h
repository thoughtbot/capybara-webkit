#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>

class NetworkAccessManager : public QNetworkAccessManager {

  Q_OBJECT

  public:
    NetworkAccessManager(QObject *parent = 0);
    void addHeader(QString key, QString value);
    void resetHeaders();
    void setUserName(const QString &userName);
    void setPassword(const QString &password);

  protected:
    QNetworkReply* createRequest(QNetworkAccessManager::Operation op, const QNetworkRequest &req, QIODevice * outgoingData);
    QString m_userName;
    QString m_password;

  private:
    QHash<QString, QString> m_headers;

  private slots:
    void provideAuthentication(QNetworkReply *reply, QAuthenticator *authenticator);

  signals:
    void requestCreated(QNetworkReply *reply);
};
