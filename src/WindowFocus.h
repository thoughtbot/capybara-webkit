#include "SocketCommand.h"

class WindowFocus : public SocketCommand {
  Q_OBJECT

  public:
    WindowFocus(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();

  private:
    void success(WebPage *);
    void windowNotFound();
    void focusWindow(QString);
};

