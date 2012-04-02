#include "Command.h"

class WebPage;

class SetTimeout : public Command {
  Q_OBJECT;

 public:
  SetTimeout(WebPage *page, QStringList &arguments, QObject *parent = 0);
  virtual void start();
};
