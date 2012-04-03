#include "Command.h"

class WebPage;

class Header : public Command {
  Q_OBJECT

  public:
    Header(WebPage *page, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};
