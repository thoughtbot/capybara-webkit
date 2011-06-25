#include "Command.h"

class WebPage;

class UserAgent : public Command {
  Q_OBJECT

  public:
    UserAgent(WebPage *page, QObject *parent = 0);
    virtual void start(QStringList &arguments);
};