#include "SocketCommand.h"

#ifndef QTWEBKIT_VERSION_STR
#include "qtwebkitversion.h"
#endif

class Version : public SocketCommand {
  Q_OBJECT

  public:
    Version(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

