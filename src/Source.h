#include "Command.h"

class WebPage;

class Source : public Command {
  Q_OBJECT

  public:
    Source(WebPage *page, QObject *parent = 0);
    virtual void start(QStringList &arguments);
};

