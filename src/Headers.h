#include "Command.h"

class Headers : public Command {
  Q_OBJECT

  public:
    Headers(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

