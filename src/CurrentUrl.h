#include "Command.h"

class WebPage;

class CurrentUrl : public Command {
  Q_OBJECT

  public:
    CurrentUrl(WebPage *page, QObject *parent = 0);
    virtual void start(QStringList &arguments);

  private:
    bool wasRegularLoad();
    bool wasRedirectedAndNotModifiedByJavascript();
};

