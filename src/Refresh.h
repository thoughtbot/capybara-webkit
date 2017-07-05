#include "SocketCommand.h"

class Refresh : public SocketCommand {
  Q_OBJECT

  public:
    Refresh(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

