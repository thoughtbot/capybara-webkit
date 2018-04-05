#include "SocketCommand.h"

class FrameUrl : public SocketCommand {
  Q_OBJECT

  public:
    FrameUrl(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

