#include "Command.h"

class WebPage;

class SetProxy : public Command {
  Q_OBJECT;

 public:
  SetProxy(WebPage *page, QStringList &arguments, QObject *parent = 0);
  virtual void start();
};
