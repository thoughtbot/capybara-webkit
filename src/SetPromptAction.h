#include "Command.h"

class SetPromptAction : public Command {
  Q_OBJECT;

 public:
  SetPromptAction(WebPageManager *manager, QStringList &arguments, QObject *parent = 0);
  virtual void start();
};
