#include "Command.h"

class ConsoleMessages : public Command {
  Q_OBJECT

  public:
    ConsoleMessages(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

