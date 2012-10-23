#include "SocketCommand.h"

class CurrentUrl : public SocketCommand {
  Q_OBJECT

  public:
    CurrentUrl(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();
#if QT_VERSION < QT_VERSION_CHECK(4, 8, 0)

    private:
      bool wasRegularLoad();
      bool wasRedirectedAndNotModifiedByJavascript();
#endif
};

