#include "Command.h"

class WebPage;

class Body : public Command {
  Q_OBJECT

  public:
    Body(WebPage *page, QObject *parent = 0);
    virtual void start(QStringList &arguments);
};

