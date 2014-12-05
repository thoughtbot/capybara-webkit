#include <QNetworkAccessManager>
#include <QWebFrame>

class NetworkReplyProxy;

class FrameResponseTracker : public QObject {
  Q_OBJECT

  public:
    FrameResponseTracker(
      QNetworkAccessManager *,
      QWebFrame *,
      QObject *parent = 0
    );

  private slots:
    void replyFinished(QUrl &, QNetworkReply *);

  private:
    void setFrameProperties(QWebFrame *, QUrl &, NetworkReplyProxy *);

    QNetworkAccessManager *m_networkAccessManager;
    QWebFrame *m_frame;
};
