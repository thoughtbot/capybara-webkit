#include "Command.h"

class Reset : public Command {
  Q_OBJECT

  public:
    Reset(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

