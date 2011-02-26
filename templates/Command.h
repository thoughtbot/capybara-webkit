#include "Command.h"

class WebPage;

class NAME : public Command {
  Q_OBJECT

  public:
    NAME(WebPage *page, QObject *parent = 0);
    virtual void start(QStringList &arguments);
};

