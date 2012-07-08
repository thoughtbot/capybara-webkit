#include "SocketCommand.h"

class ResizeWindow : public SocketCommand {
  Q_OBJECT

  public:
    ResizeWindow(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

