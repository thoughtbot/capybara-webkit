#include "Command.h"

class SetSkipImageLoading : public Command {
  Q_OBJECT

  public:
    SetSkipImageLoading(WebPageManager *manager, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};
