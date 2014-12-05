#include <QObject>

class QNetworkReply;

class UnsupportedContentReply : public QObject {
  Q_OBJECT

  public:
    UnsupportedContentReply(QNetworkReply *reply, QObject *parent = 0);
    void send();

  signals:
    void replyFinished(QNetworkReply *, QByteArray &);

  private slots:
    void readReply();

  private:
    void readReplyWhenFinished();

    QNetworkReply *m_reply;
};
