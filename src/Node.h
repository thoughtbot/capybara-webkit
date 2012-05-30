#include "Command.h"
#include <QStringList>

class Node : public Command {
  Q_OBJECT

  public:
    Node(WebPageManager *manager, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

