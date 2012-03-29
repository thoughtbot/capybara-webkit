#include "Command.h"

class WebPage;

class WindowFocus : public Command {
  Q_OBJECT

  public:
    WindowFocus(WebPage *page, QStringList &arguments, QObject *parent = 0);
    virtual void start();

  private:
    void success(WebPage *);
    void windowNotFound();
    void focusWindow(QString);
};

