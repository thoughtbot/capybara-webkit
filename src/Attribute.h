#include "Command.h"
#include <QStringList>

class WebPage;

class Attribute : public Command {
  Q_OBJECT

  public:
    Attribute(WebPage *page, QObject *parent = 0);
    virtual void start(QStringList &arguments);
};

