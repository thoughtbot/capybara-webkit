#include "Command.h"

class Find : public Command {
  Q_OBJECT

  public:
    Find(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};


