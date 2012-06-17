#include "Command.h"

class SetConfirmAction : public Command {
  Q_OBJECT;

 public:
  SetConfirmAction(WebPageManager *manager, QStringList &arguments, QObject *parent = 0);
  virtual void start();
};
