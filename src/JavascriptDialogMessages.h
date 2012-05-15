#include "Command.h"

class WebPage;

class JavascriptDialogMessages : public Command {
  Q_OBJECT

  public:
    JavascriptDialogMessages(WebPage *page, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};

