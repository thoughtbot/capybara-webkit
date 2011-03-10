#include "Command.h"

class WebPage;

class Show : public Command {
  Q_OBJECT

  public:
    Show(WebPage *page, QObject *parent = 0);
    virtual void start(QStringList &arguments);
};

