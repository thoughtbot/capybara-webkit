#include "Command.h"

class WindowFocus : public Command {
  Q_OBJECT

  public:
    WindowFocus(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();

  private:
    void success(WebPage *);
    void windowNotFound();
    void focusWindow(QString);
};

