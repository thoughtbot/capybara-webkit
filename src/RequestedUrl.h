#include "Command.h"

class WebPage;

class RequestedUrl : public Command {
  Q_OBJECT

  public:
    RequestedUrl(WebPage *page, QObject *parent = 0);
    virtual void start(QStringList &arguments);
};

