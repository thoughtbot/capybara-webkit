#include "Command.h"

class WebPage;

class SetPromptAction : public Command {
  Q_OBJECT;

 public:
  SetPromptAction(WebPage *page, QStringList &arguments, QObject *parent = 0);
  virtual void start();
};
