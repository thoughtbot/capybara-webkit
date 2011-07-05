#include <QObject>

class QTcpServer;
class WebPage;

class Server : public QObject {
  Q_OBJECT

  public:
    Server(QObject *parent = 0);
    bool start(int port);

  public slots:
    void handleConnection();

  private:
    QTcpServer *m_tcp_server;
    WebPage *m_page;
};

