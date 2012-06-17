#include "Command.h"

class WebPage;

class JavascriptConfirmMessages : public Command {
  Q_OBJECT

  public:
    JavascriptConfirmMessages(WebPage *page, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};
