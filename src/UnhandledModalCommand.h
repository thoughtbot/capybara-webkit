#include <QObject>
#include <QStringList>
#include "Command.h"

class Response;
class WebPageManager;

class UnhandledModalCommand : public Command {
  Q_OBJECT

  public:
    UnhandledModalCommand(Command *command, WebPageManager *page, QObject *parent = 0);
    virtual void start();

  public slots:
    void commandFinished(Response *response);

  private:
    WebPageManager *m_manager;
    Command *m_command;
};

