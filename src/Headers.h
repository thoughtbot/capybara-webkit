#include "Command.h"

class WebPage;

class Headers : public Command {
  Q_OBJECT

  public:
    Headers(WebPage *page, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

