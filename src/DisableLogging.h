#include "SocketCommand.h"

class WebPageManager;

class DisableLogging : public SocketCommand {
  Q_OBJECT

  public:
    DisableLogging(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

