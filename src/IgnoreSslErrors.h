#include "Command.h"

class WebPage;

class IgnoreSslErrors : public Command {
  Q_OBJECT

  public:
    IgnoreSslErrors(WebPage *page, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

