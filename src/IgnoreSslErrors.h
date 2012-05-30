#include "Command.h"

class IgnoreSslErrors : public Command {
  Q_OBJECT

  public:
    IgnoreSslErrors(WebPageManager *manager, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

