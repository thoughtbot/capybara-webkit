#include "Command.h"

class SetCookie : public Command {
  Q_OBJECT;

 public:
  SetCookie(WebPageManager *, QStringList &arguments, QObject *parent = 0);
  virtual void start();
};
