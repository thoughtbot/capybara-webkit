#include "SocketCommand.h"

class QNetworkReply;

class Source : public SocketCommand {
  Q_OBJECT

  public:
    Source(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();

  public slots:
    void sourceLoaded();

  private:
    QNetworkReply *reply;
};

