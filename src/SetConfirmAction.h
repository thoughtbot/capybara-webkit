#include "Command.h"

class WebPage;

class SetConfirmAction : public Command {
  Q_OBJECT;

 public:
  SetConfirmAction(WebPage *page, QStringList &arguments, QObject *parent = 0);
  virtual void start();
};
