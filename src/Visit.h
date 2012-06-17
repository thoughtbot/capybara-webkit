#include "Command.h"

class Visit : public Command {
  Q_OBJECT

  public:
    Visit(WebPageManager *manager, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

