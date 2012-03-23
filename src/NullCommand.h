#include "Command.h"

class WebPage;

class NullCommand : public Command {
  Q_OBJECT

  public:
    NullCommand(WebPage *page, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};
