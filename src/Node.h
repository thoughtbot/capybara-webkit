#include "Command.h"
#include <QStringList>

class WebPage;

class Node : public Command {
  Q_OBJECT

  public:
    Node(WebPage *page, QObject *parent = 0);
    virtual void start(QStringList &arguments);
};

