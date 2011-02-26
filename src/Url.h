#include "Command.h"

class WebPage;

class Url : public Command {
  Q_OBJECT

  public:
    Url(WebPage *page, QObject *parent = 0);
    virtual void start(QStringList &argments);
};

