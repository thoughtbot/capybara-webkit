#include "Command.h"

class WebPage;

class GetTimeout : public Command {
  Q_OBJECT;

 public:
  GetTimeout(WebPage *page, QStringList &arguments, QObject *parent = 0);
  virtual void start();
};
