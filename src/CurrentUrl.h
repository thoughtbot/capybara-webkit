#include "Command.h"

class CurrentUrl : public Command {
  Q_OBJECT

  public:
    CurrentUrl(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();

  private:
    bool wasRegularLoad();
    bool wasRedirectedAndNotModifiedByJavascript();
};

