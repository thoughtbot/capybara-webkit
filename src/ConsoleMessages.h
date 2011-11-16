#include "Command.h"

class WebPage;

class ConsoleMessages : public Command {
  Q_OBJECT

  public:
    ConsoleMessages(WebPage *page, QObject *parent = 0);
    virtual void start(QStringList &arguments);
};

