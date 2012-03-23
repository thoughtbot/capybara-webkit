#include "Command.h"
#include <QStringList>

class WebPage;

class Render : public Command {
  Q_OBJECT

  public:
    Render(WebPage *page, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};
