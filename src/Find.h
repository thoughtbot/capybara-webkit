#include "Command.h"

class WebPage;

class Find : public Command {
  Q_OBJECT

  public:
    Find(WebPage *page, QObject *parent = 0);
    virtual void start(QStringList &arguments);
};


