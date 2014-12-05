#include <QObject>
#include <QWebPage>
#include <QNetworkReply>

class UnsupportedContentHandler : public QObject {
  Q_OBJECT

  public:
    UnsupportedContentHandler(QWebPage *page, QObject *parent);

  signals:
    void replyFinished(QNetworkReply *reply);

  private slots:
    void unsupportedContent(QNetworkReply *reply);
    void renderReply(QNetworkReply *reply, QByteArray &text);

  private:
    QWebPage *m_page;
};
