#include "Command.h"
#include "NetworkAccessManager.h"
#include <QMap>
#include <QString>

extern const QMap<QString, QNetworkAccessManager::Operation>
  operations_by_name;

class WebPage;

class CustomRequest : public Command {
  Q_OBJECT

  public:
    CustomRequest(WebPage *page, QObject *parent = 0);
    virtual void start(QStringList &arguments);

  private slots:
    void loadFinished(bool success);
};
