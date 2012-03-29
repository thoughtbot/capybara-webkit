#include "Command.h"

class WebPage;

class ResizeWindow : public Command {
  Q_OBJECT

  public:
    ResizeWindow(WebPage *page, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

