#include "SocketCommand.h"

class FindCss : public SocketCommand {
  Q_OBJECT

  public:
    FindCss(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};


