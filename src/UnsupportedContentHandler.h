#include <QObject>
class WebPage;
class QNetworkReply;
class UnsupportedContentHandler : public QObject {
  Q_OBJECT

  public:
    UnsupportedContentHandler(WebPage *page, QNetworkReply *reply, QObject *parent = 0);

  public slots:
    void handleUnsupportedContent();

  private:
    WebPage *m_page;
    QNetworkReply *m_reply;
    void loadUnsupportedContent();
    void finish(bool success);
};
