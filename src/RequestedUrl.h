#include "Command.h"

class WebPage;

class RequestedUrl : public Command {
  Q_OBJECT

  public:
    RequestedUrl(WebPage *page, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

