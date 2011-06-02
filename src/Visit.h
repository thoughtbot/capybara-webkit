#include "Command.h"

class WebPage;

class Visit : public Command {
  Q_OBJECT

  public:
    Visit(WebPage *page, QObject *parent = 0);
    virtual void start(QStringList &arguments);

  private slots:
    void loadFinished(bool success);
};

