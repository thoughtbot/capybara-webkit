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
    void commandReady(Command *command);
    void finishCommand(Response *response);
    void pendingLoadFinished(bool success);
    void pageLoadingFromCommand();

  private:
    void startCommand();
    void writeResponse(Response *response);
    void writePageLoadFailure();

    QTcpSocket *m_socket;
    Command *m_runningCommand;
    Command *m_queuedCommand;
    WebPage *m_page;
    CommandParser *m_commandParser;
    CommandFactory *m_commandFactory;
    bool m_pageSuccess;
    bool m_commandWaiting;
    bool m_pageLoadingFromCommand;
    Response *m_pendingResponse;
};

