#include "SocketCommand.h"
#include <QStringList>

class IgnoreMessage : public SocketCommand {
  Q_OBJECT

  public:
    IgnoreMessage(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();

  private:
    static QStringList patterns;
    static void messageHandler(QtMsgType type, const char *msg);
};

