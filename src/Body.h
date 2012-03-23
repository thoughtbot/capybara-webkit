#include "Command.h"

class WebPage;

class Body : public Command {
  Q_OBJECT

  public:
    Body(WebPage *page, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

