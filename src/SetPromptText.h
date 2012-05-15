#include "Command.h"

class WebPage;

class SetPromptText : public Command {
  Q_OBJECT;

 public:
  SetPromptText(WebPage *page, QStringList &arguments, QObject *parent = 0);
  virtual void start();
};
