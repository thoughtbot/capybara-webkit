#include "Command.h"

class WebPage;

class ClearCookies : public Command {
  Q_OBJECT;

 public:
  ClearCookies(WebPage *page, QObject *parent = 0);
  virtual void start(QStringList &arguments);
};
