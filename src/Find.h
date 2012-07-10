#include "SocketCommand.h"

class Find : public SocketCommand {
  Q_OBJECT

  public:
    Find(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};


