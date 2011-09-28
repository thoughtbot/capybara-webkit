#include <QObject>

class QTcpServer;
class WebPage;

class Server : public QObject {
  Q_OBJECT

  public:
    Server(QObject *parent, bool ignoreSslErrors);
    bool start();
    quint16 server_port() const;

  public slots:
    void handleConnection();

  private:
    QTcpServer *m_tcp_server;
    WebPage *m_page;
};

