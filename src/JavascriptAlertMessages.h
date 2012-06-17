#include "Command.h"

class WebPage;

class JavascriptAlertMessages : public Command {
  Q_OBJECT

  public:
    JavascriptAlertMessages(WebPage *page, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};
