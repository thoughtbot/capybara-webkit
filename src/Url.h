#include "Command.h"

class Url : public Command {
  Q_OBJECT

  public:
    Url(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

