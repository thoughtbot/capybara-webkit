#include "Command.h"

class ClearCookies : public Command {
  Q_OBJECT;

 public:
  ClearCookies(WebPageManager *, QStringList &arguments, QObject *parent = 0);
  virtual void start();
};
