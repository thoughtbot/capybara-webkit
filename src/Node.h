#include "Command.h"
#include <QStringList>

class WebPage;

class Node : public Command {
  Q_OBJECT

  public:
    Node(WebPage *page, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

