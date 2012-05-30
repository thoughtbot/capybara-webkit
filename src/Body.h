#include "Command.h"

class Body : public Command {
  Q_OBJECT

  public:
    Body(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

