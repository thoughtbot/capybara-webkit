#include "Command.h"

class WebPage;

class NAME : public Command {
  Q_OBJECT

  public:
    NAME(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

