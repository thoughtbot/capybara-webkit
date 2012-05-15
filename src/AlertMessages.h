#include "Command.h"

class WebPage;

class AlertMessages : public Command {
  Q_OBJECT

  public:
    AlertMessages(WebPage *page, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

