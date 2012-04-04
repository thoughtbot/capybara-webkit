#include "Command.h"

class GetWindowHandles : public Command {
  Q_OBJECT

  public:
    GetWindowHandles(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

