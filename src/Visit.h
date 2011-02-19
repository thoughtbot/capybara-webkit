#include "Command.h"

class WebPage;

class Visit : public Command {
  Q_OBJECT

  public:
    Visit(WebPage *page, QObject *parent = 0);
    virtual void receivedArgument(const char *argument);

  private slots:
    void loadFinished(bool success);
};


