#include "Command.h"

class WebPage;

class SetSkipImageLoading : public Command {
  Q_OBJECT

  public:
    SetSkipImageLoading(WebPage *page, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};
