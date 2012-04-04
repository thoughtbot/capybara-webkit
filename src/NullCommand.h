#include "Command.h"

class NullCommand : public Command {
  Q_OBJECT

  public:
    NullCommand(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};
