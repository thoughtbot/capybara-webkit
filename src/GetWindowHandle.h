#include "Command.h"

class WebPage;

class GetWindowHandle : public Command {
  Q_OBJECT

  public:
    GetWindowHandle(WebPage *page, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

