#include "Command.h"

class Execute : public Command {
  Q_OBJECT

  public:
    Execute(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

