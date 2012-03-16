#include "Command.h"

class WebPage;

class ClearCookies : public Command {
  Q_OBJECT;

 public:
  ClearCookies(WebPage *page, QStringList &arguments, QObject *parent = 0);
  virtual void start();
};
