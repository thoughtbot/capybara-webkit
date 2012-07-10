#include "SocketCommand.h"

class Url : public SocketCommand {
  Q_OBJECT

  public:
    Url(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

