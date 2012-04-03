#include <QObject>
#include <QStringList>

class Command;
class Response;
class WebPage;

/*
 * Decorates a Command by deferring the finished() signal until any pending
 * page loads are complete.
 *
 * If a Command starts a page load, no signal will be emitted until the page
 * load is finished.
 *
 * If a pending page load fails, the command's response will be discarded and a
 * failure response will be emitted instead.
 */
class PageLoadingCommand : public QObject {
  Q_OBJECT

  public:
    PageLoadingCommand(Command *command, WebPage *page, QObject *parent = 0);
    void start();

  public slots:
    void pageLoadingFromCommand();
    void pendingLoadFinished(bool success);
    void commandFinished(Response *response);

  signals:
    void finished(Response *response);

  private:
    WebPage *m_page;
    Command *m_command;
    Response *m_pendingResponse;
    bool m_pageSuccess;
    bool m_pageLoadingFromCommand;
};

