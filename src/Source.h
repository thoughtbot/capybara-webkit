#include "Command.h"

class WebPage;
class QNetworkReply;

class Source : public Command {
  Q_OBJECT

  public:
    Source(WebPage *page, QObject *parent = 0);
    virtual void start(QStringList &arguments);

  public slots:
    void sourceLoaded();

  private:
    QNetworkReply *reply;
};

