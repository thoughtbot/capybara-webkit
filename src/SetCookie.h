#include "Command.h"

class WebPage;

class SetCookie : public Command {
  Q_OBJECT;

 public:
  SetCookie(WebPage *page, QObject *parent = 0);
  virtual void start(QStringList &arguments);
};
