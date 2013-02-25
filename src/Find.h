#include "JavascriptCommand.h"

class Find : public JavascriptCommand {
  Q_OBJECT

  public:
    Find(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};


