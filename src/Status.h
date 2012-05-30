#include "Command.h"

class Status : public Command {
  Q_OBJECT

  public:
    Status(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

