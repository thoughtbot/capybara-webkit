#include "Command.h"

class SetPromptText : public Command {
  Q_OBJECT;

 public:
  SetPromptText(WebPageManager *manager, QStringList &arguments, QObject *parent = 0);
  virtual void start();
};
