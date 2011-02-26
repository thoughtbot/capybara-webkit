#include "Command.h"

class WebPage;

class Execute : public Command {
  Q_OBJECT

  public:
    Execute(WebPage *page, QObject *parent = 0);
    virtual void start(QStringList &arguments);
};

