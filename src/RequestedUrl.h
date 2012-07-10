#include "SocketCommand.h"

class RequestedUrl : public SocketCommand {
  Q_OBJECT

  public:
    RequestedUrl(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

