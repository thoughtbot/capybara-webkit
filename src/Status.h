#include "Command.h"

class WebPage;

class Status : public Command {
  Q_OBJECT

  public:
    Status(WebPage *page, QObject *parent = 0);
    virtual void start(QStringList &arguments);
};

