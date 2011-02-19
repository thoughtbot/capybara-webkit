#include <QObject>

class QTcpSocket;
class WebPage;
class Command;

class Connection : public QObject {
  Q_OBJECT

  public:
    Connection(QTcpSocket *socket, WebPage *page, QObject *parent = 0);

  public slots:
    void checkNext();
    void finishCommand(bool success, QString &response);

  private:
    void readNext();
    Command *startCommand(const char *name);

    QTcpSocket *m_socket;
    Command *m_command;
    WebPage *m_page;
};

