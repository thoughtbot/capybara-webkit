#include "Command.h"

class WebPage;

class GetWindowHandles : public Command {
  Q_OBJECT

  public:
    GetWindowHandles(WebPage *page, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

