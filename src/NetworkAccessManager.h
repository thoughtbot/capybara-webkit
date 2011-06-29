#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>

class NetworkAccessManager : public QNetworkAccessManager {

  Q_OBJECT

  public:
    NetworkAccessManager(QObject *parent = 0);
    void addHeader(QString key, QString value);

  protected:
    QNetworkReply* createRequest(QNetworkAccessManager::Operation op, const QNetworkRequest &req, QIODevice * outgoingData);

  private:
    QHash<QString, QString> m_headers;
};