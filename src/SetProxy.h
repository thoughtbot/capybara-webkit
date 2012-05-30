#include "Command.h"

class SetProxy : public Command {
  Q_OBJECT;

 public:
  SetProxy(WebPageManager *, QStringList &arguments, QObject *parent = 0);
  virtual void start();
};
