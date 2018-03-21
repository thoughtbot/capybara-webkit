#include "SocketCommand.h"

class FrameTitle : public SocketCommand {
  Q_OBJECT

  public:
    FrameTitle(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

