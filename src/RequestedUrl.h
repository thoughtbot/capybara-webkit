#include "Command.h"

class RequestedUrl : public Command {
  Q_OBJECT

  public:
    RequestedUrl(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

