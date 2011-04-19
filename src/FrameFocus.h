#include "Command.h"

class WebPage;

class FrameFocus : public Command {
  Q_OBJECT

  public:
    FrameFocus(WebPage *page, QObject *parent = 0);
    virtual void start(QStringList &arguments);
};

