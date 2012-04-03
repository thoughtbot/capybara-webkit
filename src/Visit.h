#include "Command.h"

class WebPage;

class Visit : public Command {
  Q_OBJECT

  public:
    Visit(WebPage *page, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

