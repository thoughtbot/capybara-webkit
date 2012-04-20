#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <QStringList>

class NetworkAccessManager : public QNetworkAccessManager {

  Q_OBJECT

  public:
    NetworkAccessManager(QObject *parent = 0);
    void addHeader(QString key, QString value);
    void setUrlBlacklist(QStringList blacklist);

  protected:
    QNetworkReply* createRequest(QNetworkAccessManager::Operation op, const QNetworkRequest &req, QIODevice * outgoingData);

  private:
    bool isBlacklisted(QUrl url);
    QNetworkReply* noOpRequest();
    QHash<QString, QString> m_headers;
    QList<QUrl> m_urlBlacklist;
};
