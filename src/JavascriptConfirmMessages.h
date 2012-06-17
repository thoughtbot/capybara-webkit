#include "Command.h"

class JavascriptConfirmMessages : public Command {
  Q_OBJECT

  public:
    JavascriptConfirmMessages(WebPageManager *manager, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};
