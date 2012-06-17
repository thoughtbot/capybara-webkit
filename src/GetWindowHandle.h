#include "Command.h"

class GetWindowHandle : public Command {
  Q_OBJECT

  public:
    GetWindowHandle(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

