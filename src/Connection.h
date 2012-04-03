#include <QObject>
#include <QStringList>

class QTcpSocket;
class WebPage;
class Command;
class Response;
class CommandParser;
class CommandFactory;
class PageLoadingCommand;
class QTimer;

class Connection : public QObject {
  Q_OBJECT

  public:
    Connection(QTcpSocket *socket, WebPage *page, QObject *parent = 0);

  public slots:
    void commandReady(Command *command);
    void finishCommand(Response *response);
    void pageLoadStarted();
    void pendingLoadFinished(bool success);
    void pageLoadTimeout();

  private:
    void startCommand();
    void writeResponse(Response *response);
    void writePageLoadFailure();
    void writeCommandTimeout();

    QTcpSocket *m_socket;
    Command *m_queuedCommand;
    WebPage *m_page;
    CommandParser *m_commandParser;
    CommandFactory *m_commandFactory;
    PageLoadingCommand *m_runningCommand;
    QTimer *m_timer;
    bool m_pageSuccess;
    bool m_commandWaiting;
    bool m_commandTimedOut;
};

