#include <QObject>
#include <QStringList>

class QTcpSocket;
class WebPage;
class Command;
class Response;
class CommandParser;
class CommandFactory;
class PageLoadingCommand;
class WebPageManager;

class Connection : public QObject {
  Q_OBJECT

  public:
    Connection(QTcpSocket *socket, WebPageManager *manager, QObject *parent = 0);

  public slots:
    void commandReady(Command *command);
    void finishCommand(Response *response);
    void pendingLoadFinished(bool success);

  private:
    void startCommand();
    void writeResponse(Response *response);
    void writePageLoadFailure();

    QTcpSocket *m_socket;
    Command *m_queuedCommand;
    WebPageManager *m_manager;
    CommandParser *m_commandParser;
    CommandFactory *m_commandFactory;
    PageLoadingCommand *m_runningCommand;
    bool m_pageSuccess;
    bool m_commandWaiting;
    WebPage *currentPage();
};

