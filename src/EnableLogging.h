#include "Command.h"

class WebPageManager;

class EnableLogging : public Command {
  Q_OBJECT

  public:
    EnableLogging(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

