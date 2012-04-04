#include "Command.h"

class ResizeWindow : public Command {
  Q_OBJECT

  public:
    ResizeWindow(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

