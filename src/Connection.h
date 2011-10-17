#include <QObject>
#include <QStringList>

class QTcpSocket;
class WebPage;
class Command;
class Response;
class CommandParser;
class CommandFactory;

class Connection : public QObject {
  Q_OBJECT

  public:
    Connection(QTcpSocket *socket, WebPage *page, QObject *parent = 0);

  public slots:
    void commandReady(QString commandName, QStringList arguments);
    void finishCommand(Response *response);
    void pendingLoadFinished(bool success);

  private:
    void startCommand();
    void writeResponse(Response *response);

    QTcpSocket *m_socket;
    QString m_commandName;
    Command *m_command;
    QStringList m_arguments;
    WebPage *m_page;
    CommandParser *m_commandParser;
    CommandFactory *m_commandFactory;
    bool m_pageSuccess;
    bool m_commandWaiting;
};

