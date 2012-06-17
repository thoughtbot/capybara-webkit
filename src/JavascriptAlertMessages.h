#include "Command.h"

class JavascriptAlertMessages : public Command {
  Q_OBJECT

  public:
    JavascriptAlertMessages(WebPageManager *manager, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};
