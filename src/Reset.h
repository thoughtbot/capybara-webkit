#include "Command.h"

class WebPage;

class Reset : public Command {
  Q_OBJECT

  public:
    Reset(WebPage *page, QStringList &arguments, QObject *parent = 0);
    virtual void start();

  private:
    void resetHistory();
};

