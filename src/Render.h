#include "Command.h"
#include <QStringList>

class Render : public Command {
  Q_OBJECT

  public:
    Render(WebPageManager *page, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};
