#include "Command.h"

class Header : public Command {
  Q_OBJECT

  public:
    Header(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};
