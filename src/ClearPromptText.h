#include "Command.h"

class ClearPromptText : public Command {
  Q_OBJECT;

 public:
  ClearPromptText(WebPageManager *manager, QStringList &arguments, QObject *parent = 0);
  virtual void start();
};
