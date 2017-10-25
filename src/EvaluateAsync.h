#include "SocketCommand.h"

#include <QVariantList>

class EvaluateAsync : public SocketCommand {
  Q_OBJECT

  public:
    EvaluateAsync(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();
    Q_INVOKABLE void asyncResult(QVariant result);
    Q_INVOKABLE void asyncResult(QVariantList result);
};

